# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUsers::AuthenticateSession do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure and does not count sign-in attempt' do
        _admin_user = create(:admin_user, email: 'admin.user@upper.town', password: 'testpass')
        session = AdminUsers::Session.new(email: 'admin.user@upper.town', password: 'testpass')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_authenticate_session:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '3')

        result = described_class.new(session, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many attempts/)
        expect(AdminUsers::CountSignInAttemptsJob).not_to have_enqueued_sidekiq_job
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('4')
      end
    end

    context 'when admin_user is not found' do
      it 'returns failure and does not count sign-in attempt' do
        session = AdminUsers::Session.new(email: 'admin.user@upper.town', password: 'testpass')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_authenticate_session:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '0')

        result = described_class.new(session, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Incorrect password or email/)
        expect(AdminUsers::CountSignInAttemptsJob).not_to have_enqueued_sidekiq_job
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
      end
    end

    context 'when admin_user is found' do
      context 'when authentication fails' do
        it 'returns failure and counts sign-in attempt' do
          _admin_user = create(:admin_user, email: 'admin.user@upper.town', password: 'testpass')
          session = AdminUsers::Session.new(email: 'admin.user@upper.town', password: 'xxxxxxxx')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_authenticate_session:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(session, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Incorrect password or email/)
          expect(AdminUsers::CountSignInAttemptsJob).to have_enqueued_sidekiq_job('admin.user@upper.town', false)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end

      context 'when authentication succeeds' do
        it 'returns success and counts sign-in attempt' do
          admin_user = create(:admin_user, email: 'admin.user@upper.town', password: 'testpass')
          session = AdminUsers::Session.new(email: 'admin.user@upper.town', password: 'testpass')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_authenticate_session:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(session, request).call

          expect(result.success?).to be(true)
          expect(result.data[:admin_user]).to eq(admin_user)
          expect(AdminUsers::CountSignInAttemptsJob).to have_enqueued_sidekiq_job('admin.user@upper.town', true)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end
    end
  end
end
