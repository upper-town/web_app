# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_users
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
#  index_admin_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe AdminUser do
  describe 'associations' do
    it 'has many sessions' do
      admin_user = create(:admin_user)
      admin_session1 = create(:admin_session, admin_user: admin_user)
      admin_session2 = create(:admin_session, admin_user: admin_user)

      expect(admin_user.sessions).to contain_exactly(admin_session1, admin_session2)
      admin_user.destroy!
      expect { admin_session1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { admin_session2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has many tokens' do
      admin_user = create(:admin_user)
      admin_token1 = create(:admin_token, admin_user: admin_user)
      admin_token2 = create(:admin_token, admin_user: admin_user)

      expect(admin_user.tokens).to contain_exactly(admin_token1, admin_token2)
      admin_user.destroy!
      expect { admin_token1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { admin_token2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'has one account' do
      admin_user = create(:admin_user)
      admin_account = create(:admin_account, admin_user: admin_user)

      expect(admin_user.account).to eq(admin_account)
      admin_user.destroy!
      expect { admin_account.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'features' do
    it 'has secure password' do
      admin_user = build(:admin_user, email: 'admin.user@upper.town', password: 'abcd1234')

      expect(admin_user.password_digest).to be_present
      expect(admin_user.password_digest).not_to eq('abcd1234')

      admin_user.save!

      expect(
        described_class.authenticate_by(
          email: 'admin.user@upper.town', password: 'abcd1234'
        )
      ).to eq(admin_user)
    end
  end

  describe 'normalizations' do
    it 'normalizes email' do
      admin_user = create(:admin_user, email: ' admin.USER @UPPER .Town ')

      expect(admin_user.email).to eq('admin.user@upper.town')
    end

    it 'normalizes change_email' do
      admin_user = create(:admin_user, change_email: ' admin.USER @UPPER .Town ')

      expect(admin_user.change_email).to eq('admin.user@upper.town')
    end
  end

  describe 'validations' do
    it 'validates email' do
      admin_user = build(:admin_user, email: '')
      admin_user.validate
      expect(admin_user.errors.of_kind?(:email, :blank)).to be(true)

      admin_user = build(:admin_user, email: '@upper.town')
      admin_user.validate
      expect(admin_user.errors.of_kind?(:email, :format_is_not_valid)).to be(true)

      admin_user = build(:user, email: 'admin.user@example.com')
      admin_user.validate
      expect(admin_user.errors.of_kind?(:email, :domain_is_not_supported)).to be(true)
    end

    it 'validates password' do
      admin_user = build(:admin_user, password: '')
      admin_user.validate
      expect(admin_user.errors.of_kind?(:password, :blank)).to be(false)

      admin_user = build(:admin_user, password: 'abcd')
      admin_user.validate
      expect(admin_user.errors.of_kind?(:password, :too_short)).to be(true)

      admin_user = build(:admin_user, password: 'abcd1234')
      admin_user.validate
      expect(admin_user.errors.of_kind?(:password, :too_short)).to be(false)
    end
  end

  describe 'FeatureFlagIdModel' do
    describe '#to_ffid' do
      it 'returns the class name, underscore, record id' do
        admin_user = create(:admin_user)

        expect(admin_user.to_ffid).to eq("admin_user_#{admin_user.id}")
      end
    end
  end

  describe '.find_by_token' do
    context 'when purpose is blank' do
      it 'returns nil' do
        admin_user = described_class.find_by_token('', 'abcdef123456')

        expect(admin_user).to be_nil
      end
    end

    context 'when token is blank' do
      it 'returns nil' do
        admin_user = described_class.find_by_token('email_confirmation', '')

        expect(admin_user).to be_nil
      end
    end

    context 'when token is not found' do
      it 'returns nil' do
        admin_user = described_class.find_by_token('email_confirmation', 'abcdef123456')

        expect(admin_user).to be_nil
      end
    end

    context 'when token is found but expired' do
      it 'returns nil' do
        freeze_time do
          admin_token = create(
            :admin_token,
            token_digest: TokenGenerator::Admin.digest('abcdef123456'),
            expires_at: 1.second.ago
          )

          admin_user = described_class.find_by_token(admin_token.purpose, 'abcd1234')

          expect(admin_user).to be_nil
        end
      end
    end

    context 'when token is found and not expired' do
      it 'returns admin_user' do
        freeze_time do
          admin_token = create(
            :admin_token,
            token_digest: TokenGenerator::Admin.digest('abcdef123456'),
            expires_at: 1.second.from_now
          )

          admin_user = described_class.find_by_token(admin_token.purpose, 'abcdef123456')

          expect(admin_user).to eq(admin_token.admin_user)
        end
      end
    end
  end

  describe '#regenerate_token!' do
    it 'creates an AdminToken record and returns token' do
      freeze_time do
        admin_user = create(:admin_user)
        returned_token = nil

        expect do
          returned_token = admin_user.regenerate_token!('email_confirmation', 15.minutes, { 'some' => 'data' })
        end.to change(AdminToken, :count).by(1)

        admin_token = AdminToken.last
        expect(admin_token.purpose).to eq('email_confirmation')
        expect(admin_token.token_digest).to eq(TokenGenerator::Admin.digest(returned_token))
        expect(admin_token.token_last_four).to eq(returned_token.last(4))
        expect(admin_token.expires_at).to eq(15.minutes.from_now)
        expect(admin_token.data).to eq({ 'some' => 'data' })
      end
    end

    describe 'default expires_in and data' do
      it 'creates a AdminToken record and returns token' do
        freeze_time do
          admin_user = create(:admin_user)
          returned_token = nil

          expect do
            returned_token = admin_user.regenerate_token!('email_confirmation')
          end.to change(AdminToken, :count).by(1)

          admin_token = AdminToken.last
          expect(admin_token.purpose).to eq('email_confirmation')
          expect(admin_token.token_digest).to eq(TokenGenerator::Admin.digest(returned_token))
          expect(admin_token.token_last_four).to eq(returned_token.last(4))
          expect(admin_token.expires_at).to eq(1.hour.from_now)
          expect(admin_token.data).to eq({})
        end
      end
    end
  end

  describe '#confirmed_email?' do
    context 'when email_confirmed_at is blank' do
      it 'returns false' do
        admin_user = create(:admin_user, email_confirmed_at: nil)

        expect(admin_user.confirmed_email?).to be(false)
      end
    end

    context 'when email_confirmed_at is present' do
      it 'returns true' do
        admin_user = create(:admin_user, email_confirmed_at: Time.current)

        expect(admin_user.confirmed_email?).to be(true)
      end
    end
  end

  describe '#unconfirmed_email?' do
    context 'when email_confirmed_at is blank' do
      it 'returns true' do
        admin_user = create(:admin_user, email_confirmed_at: nil)

        expect(admin_user.unconfirmed_email?).to be(true)
      end
    end

    context 'when email_confirmed_at is present' do
      it 'returns false' do
        admin_user = create(:admin_user, email_confirmed_at: Time.current)

        expect(admin_user.unconfirmed_email?).to be(false)
      end
    end
  end

  describe '#confirm_email!' do
    it 'updates email_confirmed_at to the current time' do
      freeze_time do
        admin_user = create(:admin_user, email_confirmed_at: nil)

        admin_user.confirm_email!

        expect(admin_user.email_confirmed_at).to eq(Time.current)
      end
    end
  end

  describe '#unconfirm_email!' do
    it 'updates email_confirmed_at to nil' do
      admin_user = create(:admin_user, email_confirmed_at: Time.current)

      admin_user.unconfirm_email!

      expect(admin_user.email_confirmed_at).to be_nil
    end
  end

  describe '#confirmed_change_email?' do
    context 'when change_email_confirmed_at is blank' do
      it 'returns false' do
        admin_user = create(:admin_user, change_email_confirmed_at: nil)

        expect(admin_user.confirmed_change_email?).to be(false)
      end
    end

    context 'when change_email_confirmed_at is present' do
      it 'returns true' do
        admin_user = create(:admin_user, change_email_confirmed_at: Time.current)

        expect(admin_user.confirmed_change_email?).to be(true)
      end
    end
  end

  describe '#unconfirmed_change_email?' do
    context 'when change_email_confirmed_at is blank' do
      it 'returns true' do
        admin_user = create(:admin_user, change_email_confirmed_at: nil)

        expect(admin_user.unconfirmed_change_email?).to be(true)
      end
    end

    context 'when change_email_confirmed_at is present' do
      it 'returns false' do
        admin_user = create(:admin_user, change_email_confirmed_at: Time.current)

        expect(admin_user.unconfirmed_change_email?).to be(false)
      end
    end
  end

  describe '#confirm_change_email!' do
    it 'updates change_email_confirmed_at to the current time' do
      freeze_time do
        admin_user = create(:admin_user, change_email_confirmed_at: nil)

        admin_user.confirm_change_email!

        expect(admin_user.change_email_confirmed_at).to eq(Time.current)
      end
    end
  end

  describe '#unconfirm_change_email!' do
    it 'updates change_email_confirmed_at to nil' do
      admin_user = create(:admin_user, change_email_confirmed_at: Time.current)

      admin_user.unconfirm_change_email!

      expect(admin_user.change_email_confirmed_at).to be_nil
    end
  end

  describe '#revert_change_email!' do
    it 'reverts email to the previous_email' do
      freeze_time do
        admin_user = create(
          :admin_user,
          email: 'admin.user@upper.town',
          email_confirmed_at: 2.hours.ago,
          change_email: 'admin.user@upper.town',
          change_email_confirmed_at: 1.hour.ago,
          change_email_reverted_at: nil
        )

        admin_user.revert_change_email!('previous.admin.user@upper.town')

        expect(admin_user.email).to eq('previous.admin.user@upper.town')
        expect(admin_user.email_confirmed_at).to eq(Time.current)
        expect(admin_user.change_email).to be_nil
        expect(admin_user.change_email_confirmed_at).to be_nil
        expect(admin_user.change_email_reverted_at).to eq(Time.current)
      end
    end
  end

  describe '#locked?' do
    context 'when locked_at is blank' do
      it 'returns false' do
        admin_user = create(:admin_user, locked_at: nil)

        expect(admin_user.locked?).to be(false)
      end
    end

    context 'when locked_at is present' do
      it 'returns true' do
        admin_user = create(:admin_user, locked_at: Time.current)

        expect(admin_user.locked?).to be(true)
      end
    end
  end

  describe '#unlocked?' do
    context 'when locked_at is blank' do
      it 'returns true' do
        admin_user = create(:admin_user, locked_at: nil)

        expect(admin_user.unlocked?).to be(true)
      end
    end

    context 'when locked_at is present' do
      it 'returns false' do
        admin_user = create(:admin_user, locked_at: Time.current)

        expect(admin_user.unlocked?).to be(false)
      end
    end
  end

  describe '#lock_access!' do
    it 'updates locked attributes' do
      freeze_time do
        admin_user = create(:admin_user, locked_reason: nil, locked_comment: nil, locked_at: nil)

        admin_user.lock_access!('Bad Actor', 'AdminUser did bad things')

        expect(admin_user.locked_reason).to eq('Bad Actor')
        expect(admin_user.locked_comment).to eq('AdminUser did bad things')
        expect(admin_user.locked_at).to eq(Time.current)
      end
    end
  end

  describe '#unlock_access!' do
    it 'set locked attributes to nil' do
      admin_user = create(
        :admin_user,
        locked_reason: 'Bad Actor',
        locked_comment: 'AdminUser did bad things',
        locked_at: Time.current
      )

      admin_user.unlock_access!

      expect(admin_user.locked_reason).to be_nil
      expect(admin_user.locked_comment).to be_nil
      expect(admin_user.locked_at).to be_nil
    end
  end

  describe '#reset_password!' do
    it 'updates password and password_reset_at' do
      freeze_time do
        admin_user = create(:admin_user, password_digest: nil)

        admin_user.reset_password!('abcd1234')

        expect(admin_user.password_digest).to be_present
        expect(admin_user.password_digest).not_to eq('abcd1234')
        expect(admin_user.password_reset_at).to eq(Time.current)

        expect(
          described_class.authenticate_by(email: admin_user.email, password: 'abcd1234')
        ).to eq(admin_user)
      end
    end
  end
end
