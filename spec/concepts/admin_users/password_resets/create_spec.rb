# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUsers::PasswordResets::Create do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        _admin_user = create(:admin_user, email: 'admin_user@upper.town')
        password_reset = AdminUsers::PasswordReset.new(email: 'admin_user@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_password_resets_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '3')

        result = described_class.new(password_reset, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many requests/)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('4')
        expect(AdminUsers::PasswordResets::EmailJob).not_to have_enqueued_sidekiq_job
      end
    end

    context 'when admin_user is not found' do
      it 'returns success but doesn not enqueue job to send email' do
        _admin_user = create(:admin_user, email: 'admin_user@upper.town')
        password_reset = AdminUsers::PasswordReset.new(email: 'xxxxxxxx@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_password_resets_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '0')

        result = described_class.new(password_reset, request).call

        expect(result.success?).to be(true)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        expect(AdminUsers::PasswordResets::EmailJob).not_to have_enqueued_sidekiq_job
      end
    end

    context 'when admin_user is found' do
      it 'returns success and enqueues job to send email' do
        admin_user = create(:admin_user, email: 'admin_user@upper.town')
        password_reset = AdminUsers::PasswordReset.new(email: 'admin_user@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_password_resets_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '0')

        result = described_class.new(password_reset, request).call

        expect(result.success?).to be(true)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        expect(AdminUsers::PasswordResets::EmailJob).to have_enqueued_sidekiq_job(admin_user.id)
      end
    end
  end
end
