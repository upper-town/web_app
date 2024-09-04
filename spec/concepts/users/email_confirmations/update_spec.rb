# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::EmailConfirmations::Update do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        user = create(:user)
        token = user.generate_token!(:email_confirmation)
        email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_email_confirmation_update:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '3')

        result = described_class.new(email_confirmation_edit, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many attempts/)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('4')
      end
    end

    context 'when user is not found by token' do
      describe 'non-existing token' do
        it 'returns failure' do
          user = create(:user)
          _token = user.generate_token!(:email_confirmation)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: 'xxxxxxxx')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_email_confirmation_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end

      describe 'expired token' do
        it 'returns failure' do
          user = create(:user)
          token = user.generate_token!(:email_confirmation, 0.seconds)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_email_confirmation_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end
    end

    context 'when user is found by token' do
      context 'when email has already been confirmed' do
        it 'returns failure' do
          user = create(:user, email_confirmed_at: Time.current)
          token = user.generate_token!(:email_confirmation)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_email_confirmation_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Email address has already been confirmed/)
          expect(result.data[:user].email_confirmed_at).to be_present
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end

      context 'when trying to confirm email raises an error' do
        it 'raises an error and uncalls rate_limiter' do
          user = create(:user)
          token = user.generate_token!(:email_confirmation)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_email_confirmation_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')
          allow_any_instance_of(User).to receive(:confirm_email!).and_raise(ActiveRecord::ActiveRecordError)

          expect do
            described_class.new(email_confirmation_edit, request).call
          end.to raise_error(ActiveRecord::ActiveRecordError)

          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('0')
        end
      end

      context 'when trying to confirm email succeeds' do
        it 'returns success and expires tokens' do
          user = create(:user)
          token = user.generate_token!(:email_confirmation)
          email_confirmation_edit = Users::EmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_email_confirmation_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(email_confirmation_edit, request).call

          expect(result.success?).to be(true)
          expect(result.data[:user].email_confirmed_at).to be_present
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
          expect(User.find_by_token(:email_confirmation, token)).to be_blank
        end
      end
    end
  end
end
