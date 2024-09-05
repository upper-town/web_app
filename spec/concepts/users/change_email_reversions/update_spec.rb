# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::ChangeEmailReversions::Update do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        user = create(:user, email: 'user.change@upper.town')
        token = user.generate_token!(:change_email_reversion, 30.days, { email: 'user@upper.town' })
        change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_change_email_reversions_update:1.1.1.1'
        RateLimiting.redis.set(rate_limiter_key, '3')

        result = described_class.new(change_email_reversion_edit, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many attempts/)
        expect(RateLimiting.redis.get(rate_limiter_key)).to eq('4')
      end
    end

    context 'when user is not found by token' do
      describe 'non-existing token' do
        it 'returns failure' do
          user = create(:user, email: 'user.change@upper.town')
          _token = user.generate_token!(:change_email_reversion, 30.days, { email: 'user@upper.town' })
          change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: 'xxxxxxxx')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_reversions_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(change_email_reversion_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end

      describe 'expired token' do
        it 'returns failure' do
          user = create(:user, email: 'user.change@upper.town')
          token = user.generate_token!(:change_email_reversion, 0.seconds, { email: 'user@upper.town' })
          change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_reversions_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(change_email_reversion_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end
    end

    context 'when user is found by token' do
      context 'when token data does not have the old email' do
        it 'returns failure' do
          user = create(:user, email: 'user.change@upper.town')
          token = user.generate_token!(:change_email_reversion, 30.days, { email: ' ' })
          change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_reversions_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')

          result = described_class.new(change_email_reversion_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid token: old email address is not associated with token/)
          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
        end
      end

      context 'when trying to revert change_email raises an error' do
        it 'raises an error and uncalls rate_limiter' do
          user = create(:user, email: 'user.change@upper.town')
          token = user.generate_token!(:change_email_reversion, 30.days, { email: 'user@upper.town' })
          change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_reversions_update:1.1.1.1'
          RateLimiting.redis.set(rate_limiter_key, '0')
          allow_any_instance_of(User).to receive(:revert_change_email!).and_raise(ActiveRecord::ActiveRecordError)

          expect do
            described_class.new(change_email_reversion_edit, request).call
          end.to raise_error(ActiveRecord::ActiveRecordError)

          expect(RateLimiting.redis.get(rate_limiter_key)).to eq('0')
        end
      end

      context 'when trying to revert change_email succeeds' do
        it 'returns success and expires tokens' do
          freeze_time do
            user = create(:user, email: 'user.change@upper.town')
            token = user.generate_token!(:change_email_reversion, 30.days, { email: 'user@upper.town' })
            change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(token: token)
            request = TestRequestHelper.build(remote_ip: '1.1.1.1')
            rate_limiter_key = 'users_change_email_reversions_update:1.1.1.1'
            RateLimiting.redis.set(rate_limiter_key, '0')

            result = described_class.new(change_email_reversion_edit, request).call

            expect(result.success?).to be(true)
            expect(result.data[:user].email).to eq('user@upper.town')
            expect(result.data[:user].email_confirmed_at).to eq(Time.current)
            expect(result.data[:user].change_email).to be_nil
            expect(result.data[:user].change_email_confirmed_at).to be_nil
            expect(result.data[:user].change_email_reverted_at).to eq(Time.current)
            expect(RateLimiting.redis.get(rate_limiter_key)).to eq('1')
            expect(User.find_by_token(:change_email_reversion, token)).to be_nil
          end
        end
      end
    end
  end
end
