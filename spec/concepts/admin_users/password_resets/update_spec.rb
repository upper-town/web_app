# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUsers::PasswordResets::Update do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        admin_user = create(:admin_user)
        token = admin_user.generate_token!(:password_reset)
        password_reset_edit = AdminUsers::PasswordResetEdit.new(token: token)
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_password_resets_update:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '3')

        result = described_class.new(password_reset_edit, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many requests/)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('4')
      end
    end

    context 'when admin_user is not found by token' do
      describe 'non-existing token' do
        it 'returns failure' do
          admin_user = create(:admin_user)
          _token = admin_user.generate_token!(:password_reset)
          password_reset_edit = AdminUsers::PasswordResetEdit.new(token: 'xxxxxxxx')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_password_resets_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(password_reset_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end

      describe 'expired token' do
        it 'returns failure' do
          admin_user = create(:admin_user)
          token = admin_user.generate_token!(:password_reset, 0.seconds)
          password_reset_edit = AdminUsers::PasswordResetEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_password_resets_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(password_reset_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end
    end

    context 'when admin_user is found by token' do
      context 'when trying to reset password raises an error' do
        it 'raises an error and uncalls rate_limiter' do
          admin_user = create(:admin_user)
          token = admin_user.generate_token!(:password_reset)
          password_reset_edit = AdminUsers::PasswordResetEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_password_resets_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')
          allow_any_instance_of(AdminUser).to receive(:reset_password!).and_raise(ActiveRecord::ActiveRecordError)

          expect do
            described_class.new(password_reset_edit, request).call
          end.to raise_error(ActiveRecord::ActiveRecordError)

          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('0')
        end
      end

      context 'when trying to reset password succeeds' do
        it 'returns success and expires tokens' do
          admin_user = create(:admin_user)
          token = admin_user.generate_token!(:password_reset)
          password_reset_edit = AdminUsers::PasswordResetEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_password_resets_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(password_reset_edit, request).call

          expect(result.success?).to be(true)
          expect(result.data[:admin_user].password_reset_at).to be_present
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
          expect(AdminUser.find_by_token(:password_reset, token)).to be_blank
        end
      end
    end
  end
end
