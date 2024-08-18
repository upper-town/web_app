# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                                :bigint           not null, primary key
#  change_email                      :string
#  change_email_confirmation_sent_at :datetime
#  change_email_confirmed_at         :datetime
#  change_email_reversion_sent_at    :datetime
#  change_email_reverted_at          :datetime
#  email                             :string           not null
#  email_confirmation_sent_at        :datetime
#  email_confirmed_at                :datetime
#  failed_attempts                   :integer          default(0), not null
#  locked_at                         :datetime
#  locked_comment                    :text
#  locked_reason                     :string
#  password_digest                   :string
#  password_reset_at                 :datetime
#  password_reset_sent_at            :datetime
#  sign_in_count                     :integer          default(0), not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it 'has many sessions' do
      user = create(:user)
      user_session = create(:user_session, user: user)

      expect(user.sessions).to include(user_session)
      user.destroy!
      expect { user_session.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many tokens' do
      user = create(:user)
      user_token = create(:user_token, user: user)

      expect(user.tokens).to include(user_token)
      user.destroy!
      expect { user_token.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has one account' do
      user = create(:user)
      user_account = create(:user_account, user: user)

      expect(user.account).to eq(user_account)
      user.destroy!
      expect { user_account.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'features' do
    it 'has secure password' do
      user = build(:user, email: 'user@upper.town', password: 'abcd1234')

      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq('abcd1234')

      user.save!

      expect(
        described_class.authenticate_by(
          email: 'user@upper.town', password: 'abcd1234'
        )
      ).to eq(user)
    end
  end

  describe 'normalizations' do
    it 'normalizes email' do
      user = create(:user, email: ' USER @UPPER .Town ')

      expect(user.email).to eq('user@upper.town')
    end

    it 'normalizes change_email' do
      user = create(:user, change_email: ' USER @UPPER .Town ')

      expect(user.change_email).to eq('user@upper.town')
    end
  end

  describe 'validations' do
    it 'validates email' do
      user = build(:user, email: '')
      user.validate
      expect(user.errors.of_kind?(:email, :blank)).to be(true)

      user = build(:user, email: '@upper.town')
      user.validate
      expect(user.errors.of_kind?(:email, :format_is_not_valid)).to be(true)

      user = build(:user, email: 'user@example.com')
      user.validate
      expect(user.errors.of_kind?(:email, :domain_is_not_supported)).to be(true)
    end

    it 'validates password' do
      user = build(:user, password: '')
      user.validate
      expect(user.errors.of_kind?(:password, :blank)).to be(false)

      user = build(:user, password: 'abcd')
      user.validate
      expect(user.errors.of_kind?(:password, :too_short)).to be(true)

      user = build(:user, password: 'abcd1234')
      user.validate
      expect(user.errors.of_kind?(:password, :too_short)).to be(false)
    end
  end

  describe 'FeatureFlagIdModel' do
    describe '#feature_flag_id' do
      it 'returns the class name, underscore, record id' do
        user = create(:user)

        expect(user.feature_flag_id).to eq("User_#{user.id}")
      end
    end

    describe '#ffid' do
      it 'returns the class name, underscore, record id' do
        user = create(:user)

        expect(user.ffid).to eq("User_#{user.id}")
      end
    end
  end

  describe '.find_by_token' do
    context 'when purpose is blank' do
      it 'returns nil' do
        user = described_class.find_by_token('', 'abcd1234')

        expect(user).to be_nil
      end
    end

    context 'when token is blank' do
      it 'returns nil' do
        user = described_class.find_by_token('email_confirmation', '')

        expect(user).to be_nil
      end
    end

    context 'when token is not found' do
      it 'returns nil' do
        user = described_class.find_by_token('email_confirmation', 'abcd1234')

        expect(user).to be_nil
      end
    end

    context 'when token is found but expired' do
      it 'returns nil' do
        freeze_time do
          user_token = create(:user_token, expires_at: 1.second.ago)

          user = described_class.find_by_token(user_token.purpose, user_token.token)

          expect(user).to be_nil
        end
      end
    end

    context 'when token is found and not expired' do
      it 'returns user' do
        freeze_time do
          user_token = create(:user_token, expires_at: 1.second.from_now)

          user = described_class.find_by_token(user_token.purpose, user_token.token)

          expect(user).to eq(user_token.user)
        end
      end
    end
  end

  describe '#regenerate_token!' do
    it 'creates a UserToken record' do
      freeze_time do
        user = create(:user)
        returned_token = nil

        expect do
          returned_token = user.regenerate_token!('email_confirmation', 15.minutes, { 'some' => 'data' })
        end.to change(UserToken, :count).by(1)

        user_token = UserToken.last
        expect(user_token.purpose).to eq('email_confirmation')
        expect(user_token.token).to be_present
        expect(user_token.token).to eq(returned_token)
        expect(user_token.token.length).to eq(44)
        expect(user_token.expires_at).to eq(15.minutes.from_now)
        expect(user_token.data).to eq({ 'some' => 'data' })
      end
    end

    describe 'default expires_in and data' do
      it 'creates a UserToken record' do
        freeze_time do
          user = create(:user)
          returned_token = nil

          expect do
            returned_token = user.regenerate_token!('email_confirmation')
          end.to change(UserToken, :count).by(1)

          user_token = UserToken.last
          expect(user_token.purpose).to eq('email_confirmation')
          expect(user_token.token).to be_present
          expect(user_token.token).to eq(returned_token)
          expect(user_token.token.length).to eq(44)
          expect(user_token.expires_at).to eq(1.hour.from_now)
          expect(user_token.data).to eq({})
        end
      end
    end
  end

  describe '#current_token' do
    context 'when UserTokens are not found' do
      it 'returns nil' do
        user = create(:user)

        expect(user.current_token('email_confirmation')).to be_nil
      end
    end

    context 'when UserTokens are found' do
      it 'returns the latest token' do
        user = create(:user)
        _user_token1 = create(:user_token, user: user, purpose: 'email_confirmation', created_at: 1.hour.ago)
        user_token2 = create(:user_token, user: user, purpose: 'email_confirmation', created_at: 1.minute.ago)

        expect(user.current_token('email_confirmation')).to eq(user_token2.token)
      end
    end
  end

  describe '#confirmed_email?' do
    context 'when email_confirmed_at is blank' do
      it 'returns false' do
        user = create(:user, email_confirmed_at: nil)

        expect(user.confirmed_email?).to be(false)
      end
    end

    context 'when email_confirmed_at is present' do
      it 'returns true' do
        user = create(:user, email_confirmed_at: Time.current)

        expect(user.confirmed_email?).to be(true)
      end
    end
  end

  describe '#unconfirmed_email?' do
    context 'when email_confirmed_at is blank' do
      it 'returns true' do
        user = create(:user, email_confirmed_at: nil)

        expect(user.unconfirmed_email?).to be(true)
      end
    end

    context 'when email_confirmed_at is present' do
      it 'returns false' do
        user = create(:user, email_confirmed_at: Time.current)

        expect(user.unconfirmed_email?).to be(false)
      end
    end
  end

  describe '#confirm_email!' do
    it 'updates email_confirmed_at to the current time' do
      freeze_time do
        user = create(:user, email_confirmed_at: nil)

        user.confirm_email!

        expect(user.email_confirmed_at).to eq(Time.current)
      end
    end
  end

  describe '#unconfirm_email!' do
    it 'updates email_confirmed_at to nil' do
      user = create(:user, email_confirmed_at: Time.current)

      user.unconfirm_email!

      expect(user.email_confirmed_at).to be_nil
    end
  end

  describe '#confirmed_change_email?' do
    context 'when change_email_confirmed_at is blank' do
      it 'returns false' do
        user = create(:user, change_email_confirmed_at: nil)

        expect(user.confirmed_change_email?).to be(false)
      end
    end

    context 'when change_email_confirmed_at is present' do
      it 'returns true' do
        user = create(:user, change_email_confirmed_at: Time.current)

        expect(user.confirmed_change_email?).to be(true)
      end
    end
  end

  describe '#unconfirmed_change_email?' do
    context 'when change_email_confirmed_at is blank' do
      it 'returns true' do
        user = create(:user, change_email_confirmed_at: nil)

        expect(user.unconfirmed_change_email?).to be(true)
      end
    end

    context 'when change_email_confirmed_at is present' do
      it 'returns false' do
        user = create(:user, change_email_confirmed_at: Time.current)

        expect(user.unconfirmed_change_email?).to be(false)
      end
    end
  end

  describe '#confirm_change_email!' do
    it 'updates change_email_confirmed_at to the current time' do
      freeze_time do
        user = create(:user, change_email_confirmed_at: nil)

        user.confirm_change_email!

        expect(user.change_email_confirmed_at).to eq(Time.current)
      end
    end
  end

  describe '#unconfirm_change_email!' do
    it 'updates change_email_confirmed_at to nil' do
      user = create(:user, change_email_confirmed_at: Time.current)

      user.unconfirm_change_email!

      expect(user.change_email_confirmed_at).to be_nil
    end
  end

  describe '#revert_change_email!' do
    it 'reverts email to the previous_email' do
      freeze_time do
        user = create(
          :user,
          email: 'user@upper.town',
          email_confirmed_at: 2.hours.ago,
          change_email: 'user@upper.town',
          change_email_confirmed_at: 1.hour.ago,
          change_email_reverted_at: nil
        )

        user.revert_change_email!('previous.user@upper.town')

        expect(user.email).to eq('previous.user@upper.town')
        expect(user.email_confirmed_at).to eq(Time.current)
        expect(user.change_email).to be_nil
        expect(user.change_email_confirmed_at).to be_nil
        expect(user.change_email_reverted_at).to eq(Time.current)
      end
    end
  end

  describe '#locked?' do
    context 'when locked_at is blank' do
      it 'returns false' do
        user = create(:user, locked_at: nil)

        expect(user.locked?).to be(false)
      end
    end

    context 'when locked_at is present' do
      it 'returns true' do
        user = create(:user, locked_at: Time.current)

        expect(user.locked?).to be(true)
      end
    end
  end

  describe '#unlocked?' do
    context 'when locked_at is blank' do
      it 'returns true' do
        user = create(:user, locked_at: nil)

        expect(user.unlocked?).to be(true)
      end
    end

    context 'when locked_at is present' do
      it 'returns false' do
        user = create(:user, locked_at: Time.current)

        expect(user.unlocked?).to be(false)
      end
    end
  end

  describe '#lock_access!' do
    it 'updates locked attributes' do
      freeze_time do
        user = create(:user, locked_reason: nil, locked_comment: nil, locked_at: nil)

        user.lock_access!('Bad Actor', 'User did bad things')

        expect(user.locked_reason).to eq('Bad Actor')
        expect(user.locked_comment).to eq('User did bad things')
        expect(user.locked_at).to eq(Time.current)
      end
    end
  end

  describe '#unlock_access!' do
    it 'set locked attributes to nil' do
      user = create(
        :user,
        locked_reason: 'Bad Actor',
        locked_comment: 'User did bad things',
        locked_at: Time.current
      )

      user.unlock_access!

      expect(user.locked_reason).to be_nil
      expect(user.locked_comment).to be_nil
      expect(user.locked_at).to be_nil
    end
  end

  describe '#reset_password!' do
    it 'updates password and password_reset_at' do
      freeze_time do
        user = create(:user, password_digest: nil)

        user.reset_password!('abcd1234')

        expect(user.password_digest).to be_present
        expect(user.password_digest).not_to eq('abcd1234')
        expect(user.password_reset_at).to eq(Time.current)

        expect(
          described_class.authenticate_by(email: user.email, password: 'abcd1234')
        ).to eq(user)
      end
    end
  end
end
