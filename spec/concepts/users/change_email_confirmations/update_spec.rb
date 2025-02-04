# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::ChangeEmailConfirmations::Update do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        user = create(:user, email: 'user@upper.town', change_email: 'user.change@upper.town')
        token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: 'user.change@upper.town' })
        change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_change_email_confirmations_update:1.1.1.1'
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(change_email_confirmation_edit, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many attempts/)
        expect(Rails.cache.read(rate_limiter_key)).to eq(4)
      end
    end

    context 'when user is not found by token' do
      describe 'non-existing token' do
        it 'returns failure' do
          user = create(:user, email: 'user@upper.town', change_email: 'user.change@upper.town')
          _token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: 'user.change@upper.town' })
          change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: 'xxxxxxxx')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_confirmations_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(change_email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        end
      end

      describe 'expired token' do
        it 'returns failure' do
          user = create(:user, email: 'user@upper.town', change_email: 'user.change@upper.town')
          token = user.generate_token!(:change_email_confirmation, 0.seconds, { change_email: 'user.change@upper.town' })
          change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_confirmations_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(change_email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        end
      end
    end

    context 'when user is found by token' do
      context 'when change_email has already been confirmed' do
        it 'returns failure' do
          user = create(
            :user,
            email: 'user@upper.town',
            change_email: 'user.change@upper.town',
            change_email_confirmed_at: Time.current
          )
          token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: 'user.change@upper.town' })
          change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_confirmations_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(change_email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/New Email address has already been confirmed/)
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        end
      end

      context 'when token data does not have the expected change_email' do
        it 'returns failure' do
          [
            ['user1@upper.town', 'user.change1@upper.town', ' '],
            ['user2@upper.town', 'user.change2@upper.town', 'something.else@upper.town'],
            ['user3@upper.town', ' ',                       'user.change3@upper.town'],
          ].each do |email, change_email, token_data_change_email|
            user = create(:user, email: email, change_email: change_email)
            token = user.generate_token!(
              :change_email_confirmation,
              1.hour,
              { change_email: token_data_change_email }
            )
            change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)
            request = TestRequestHelper.build(remote_ip: '1.1.1.1')
            rate_limiter_key = 'users_change_email_confirmations_update:1.1.1.1'
            Rails.cache.write(rate_limiter_key, 0)

            result = described_class.new(change_email_confirmation_edit, request).call

            expect(result.failure?).to be(true)
            expect(result.errors[:base]).to include(/Invalid token: new email address is not associated with token/)
            expect(Rails.cache.read(rate_limiter_key)).to eq(1)
          end
        end
      end

      context 'when trying to confirm change_email raises an error' do
        it 'raises an error and uncalls rate_limiter' do
          user = create(:user, email: 'user@upper.town', change_email: 'user.change@upper.town')
          token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: 'user.change@upper.town' })
          change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_confirmations_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)
          allow_any_instance_of(User).to receive(:update!).and_raise(ActiveRecord::ActiveRecordError)

          expect do
            described_class.new(change_email_confirmation_edit, request).call
          end.to raise_error(ActiveRecord::ActiveRecordError)

          expect(Rails.cache.read(rate_limiter_key)).to eq(0)
        end
      end

      context 'when trying to confirm change_email succeeds' do
        it 'returns success and expires tokens' do
          freeze_time do
            user = create(:user, email: 'user@upper.town', change_email: 'user.change@upper.town')
            token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: 'user.change@upper.town' })
            change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)
            request = TestRequestHelper.build(remote_ip: '1.1.1.1')
            rate_limiter_key = 'users_change_email_confirmations_update:1.1.1.1'
            Rails.cache.write(rate_limiter_key, 0)

            result = described_class.new(change_email_confirmation_edit, request).call

            expect(result.success?).to be(true)
            expect(result.data[:user].email).to eq('user.change@upper.town')
            expect(result.data[:user].change_email).to be_blank
            expect(result.data[:user].change_email_confirmed_at).to eq(Time.current)
            expect(result.data[:user].email_confirmed_at).to eq(Time.current)
            expect(Rails.cache.read(rate_limiter_key)).to eq(1)
            expect(User.find_by_token(:change_email_confirmation, token)).to be_nil
          end
        end
      end
    end
  end
end
