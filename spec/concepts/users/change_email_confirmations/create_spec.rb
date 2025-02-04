# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::ChangeEmailConfirmations::Create do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        user = create(:user, password: 'testpass')
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: 'user.change@upper.town',
          password: 'testpass'
        )
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_change_email_confirmations_create:1.1.1.1'
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(change_email_confirmation, user.email, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many attempts/)
        expect(Rails.cache.read(rate_limiter_key)).to eq(4)
        expect(Users::ChangeEmailConfirmations::EmailJob).not_to have_been_enqueued
      end
    end

    context 'when current_user_email is different than the email provided' do
      it 'returns failure' do
        user = create(:user, password: 'testpass')
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: 'user.change@upper.town',
          password: 'testpass'
        )
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_change_email_confirmations_create:1.1.1.1'
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(change_email_confirmation, 'someone.else@upper.town', request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Incorrect current email address/)
        expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        expect(Users::ChangeEmailConfirmations::EmailJob).not_to have_been_enqueued
      end
    end

    context 'when password is incorrect' do
      it 'returns failure and fails to authenticate user' do
        user = create(:user, password: 'testpass')
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: 'user.change@upper.town',
          password: 'xxxxxxxx'
        )
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_change_email_confirmations_create:1.1.1.1'
        Rails.cache.write(rate_limiter_key, 0)

        result = described_class.new(change_email_confirmation, user.email, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Incorrect password/)
        expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        expect(Users::ChangeEmailConfirmations::EmailJob).not_to have_been_enqueued
      end
    end

    context 'when trying to update change_email raises an error' do
      it 'raises an error and uncalls rate_limiter' do
        user = create(:user, password: 'testpass')
        change_email_confirmation = Users::ChangeEmailConfirmation.new(
          email: user.email,
          change_email: 'user.change@upper.town',
          password: 'testpass'
        )
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'users_change_email_confirmations_create:1.1.1.1'
        Rails.cache.write(rate_limiter_key, 0)
        allow_any_instance_of(User).to receive(:update!).and_raise(ActiveRecord::ActiveRecordError)

        expect do
          described_class.new(change_email_confirmation, user.email, request).call
        end.to raise_error(ActiveRecord::ActiveRecordError)

        expect(Rails.cache.read(rate_limiter_key)).to eq(0)
        expect(Users::ChangeEmailConfirmations::EmailJob).not_to have_been_enqueued
      end
    end

    context 'when trying to update change_email succeeds' do
      it 'returns success and enqueues email job' do
        freeze_time do
          user = create(:user, password: 'testpass')
          change_email_confirmation = Users::ChangeEmailConfirmation.new(
            email: user.email,
            change_email: 'user.change@upper.town',
            password: 'testpass'
          )
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'users_change_email_confirmations_create:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(change_email_confirmation, user.email, request).call

          expect(result.success?).to be(true)
          expect(result.data[:user].change_email).to eq('user.change@upper.town')
          expect(result.data[:user].change_email_confirmed_at).to be_nil
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
          expect(Users::ChangeEmailConfirmations::EmailJob)
            .to have_been_enqueued
            .with(user)
            .at(30.seconds.from_now)
        end
      end
    end
  end
end
