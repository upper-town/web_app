# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::Create do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        email_confirmation = Users::EmailConfirmation.new(email: 'user@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '3')

        result = described_class.new(email_confirmation, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many requests/)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('4')
        expect(Users::EmailConfirmations::EmailJob).not_to have_enqueued_sidekiq_job
      end
    end

    context 'when user does not exist' do
      it 'returns success, creates user and sends email confirmation' do
        email_confirmation = Users::EmailConfirmation.new(email: 'user@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '0')

        result = nil
        expect do
          result = described_class.new(email_confirmation, request).call
        end.to(
          change(User, :count).by(1).and(
            change(Account, :count).by(1)
          )
        )

        user = User.last
        account = Account.last
        expect(user.email).to eq('user@upper.town')
        expect(user.account).to be_present
        expect(user.account).to eq(account)
        expect(user.email_confirmed_at).to be_blank

        expect(result.success?).to be(true)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        expect(Users::EmailConfirmations::EmailJob)
          .to have_enqueued_sidekiq_job(user.id)
          .on('critical')
      end

      context 'when an error is raised trying to create user' do
        it 'raises error and uncalls rate_limiter' do
          email_confirmation = Users::EmailConfirmation.new(email: 'user@upper.town')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_create:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')
          allow_any_instance_of(User).to receive(:save!).and_raise(ActiveRecord::ActiveRecordError)

          expect do
            described_class.new(email_confirmation, request).call
          end.to raise_error(ActiveRecord::ActiveRecordError)

          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('0')
          expect(Users::EmailConfirmations::EmailJob).not_to have_enqueued_sidekiq_job
        end
      end
    end

    context 'when user already exists' do
      it 'returns success, finds user and sends email confirmation' do
        user = create(:user, email: 'user@upper.town')
        email_confirmation = Users::EmailConfirmation.new(email: 'user@upper.town')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_create:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '0')

        result = nil
        expect do
          result = described_class.new(email_confirmation, request).call
        end.to(
          change(User, :count).by(0).and(
            change(Account, :count).by(0)
          )
        )

        expect(result.success?).to be(true)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        expect(Users::EmailConfirmations::EmailJob)
          .to have_enqueued_sidekiq_job(user.id)
          .on('critical')
      end
    end
  end
end
