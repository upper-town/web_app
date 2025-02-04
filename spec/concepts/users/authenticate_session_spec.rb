# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::AuthenticateSession do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure and does not count sign-in attempt' do
        _user = create(:user, email: 'user@upper.town', password: 'testpass')
        session = Users::Session.new(email: 'user@upper.town', password: 'testpass')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_authenticate_session:1.1.1.1'
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(session, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many attempts/)
        expect(Users::CountSignInAttemptsJob).not_to have_been_enqueued
        expect(Rails.cache.read(rate_limiter_key)).to eq(4)
      end
    end

    context 'when user is not found' do
      it 'returns failure and does not count sign-in attempt' do
        session = Users::Session.new(email: 'user@upper.town', password: 'testpass')
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_authenticate_session:1.1.1.1'
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(session, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Incorrect password or email/)
        expect(Users::CountSignInAttemptsJob).not_to have_been_enqueued
        expect(Rails.cache.read(rate_limiter_key)).to eq(1)
      end
    end

    context 'when user is found' do
      context 'when authentication fails' do
        it 'returns failure and counts sign-in attempt' do
          _user = create(:user, email: 'user@upper.town', password: 'testpass')
          session = Users::Session.new(email: 'user@upper.town', password: 'xxxxxxxx')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_authenticate_session:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(session, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Incorrect password or email/)
          expect(Users::CountSignInAttemptsJob).to have_been_enqueued.with('user@upper.town', false)
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        end
      end

      context 'when authentication succeeds' do
        it 'returns success and counts sign-in attempt' do
          user = create(:user, email: 'user@upper.town', password: 'testpass')
          session = Users::Session.new(email: 'user@upper.town', password: 'testpass')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_authenticate_session:1.1.1.1'
          Rails.cache.write(rate_limiter_key, '0')

          result = described_class.new(session, request).call

          expect(result.success?).to be(true)
          expect(result.data[:user]).to eq(user)
          expect(Users::CountSignInAttemptsJob).to have_been_enqueued.with('user@upper.town', true)
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        end
      end
    end
  end
end
