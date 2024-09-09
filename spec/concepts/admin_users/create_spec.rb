# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUsers::Create do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        email_confirmation = AdminUsers::EmailConfirmation.new(email: 'admin.user@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '3')

        result = described_class.new(email_confirmation, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many requests/)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('4')
        expect(AdminUsers::EmailConfirmations::EmailJob).not_to have_enqueued_sidekiq_job
      end
    end

    context 'when admin_user does not exist' do
      it 'returns success, creates admin_user and sends email confirmation' do
        email_confirmation = AdminUsers::EmailConfirmation.new(email: 'admin.user@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '0')

        result = nil
        expect do
          result = described_class.new(email_confirmation, request).call
        end.to(
          change(AdminUser, :count).by(1).and(
            change(AdminAccount, :count).by(1)
          )
        )

        admin_user = AdminUser.last
        admin_account = AdminAccount.last
        expect(admin_user.email).to eq('admin.user@upper.town')
        expect(admin_user.account).to be_present
        expect(admin_user.account).to eq(admin_account)
        expect(admin_user.email_confirmed_at).to be_blank

        expect(result.success?).to be(true)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        expect(AdminUsers::EmailConfirmations::EmailJob)
          .to have_enqueued_sidekiq_job(admin_user.id)
          .on('critical')
      end

      context 'when an error is raised trying to create admin_user' do
        it 'raises error and uncalls rate_limiter' do
          email_confirmation = AdminUsers::EmailConfirmation.new(email: 'admin.user@upper.town')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_create:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')
          allow_any_instance_of(AdminUser).to receive(:save!).and_raise(ActiveRecord::ActiveRecordError)

          expect do
            described_class.new(email_confirmation, request).call
          end.to raise_error(ActiveRecord::ActiveRecordError)

          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('0')
          expect(AdminUsers::EmailConfirmations::EmailJob).not_to have_enqueued_sidekiq_job
        end
      end
    end

    context 'when admin_user already exists' do
      it 'returns success, finds admin_user and sends email confirmation' do
        admin_user = create(:admin_user, email: 'admin.user@upper.town')
        email_confirmation = AdminUsers::EmailConfirmation.new(email: 'admin.user@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '0')

        result = nil
        expect do
          result = described_class.new(email_confirmation, request).call
        end.to(
          change(AdminUser, :count).by(0).and(
            change(AdminAccount, :count).by(0)
          )
        )

        expect(result.success?).to be(true)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        expect(AdminUsers::EmailConfirmations::EmailJob)
          .to have_enqueued_sidekiq_job(admin_user.id)
          .on('critical')
      end
    end
  end
end
