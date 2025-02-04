# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminUsers::EmailConfirmations::Update do
  describe '#call' do
    context 'when rate_limiter has been exceeded' do
      it 'returns failure' do
        admin_user = create(:admin_user)
        token = admin_user.generate_token!(:email_confirmation)
        email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)
        request = TestRequestHelper.build(remote_ip: '1.1.1.1')
        rate_limiter_key = 'admin_users_email_confirmation_update:1.1.1.1'
        Rails.cache.write(rate_limiter_key, 3)

        result = described_class.new(email_confirmation_edit, request).call

        expect(result.failure?).to be(true)
        expect(result.errors[:base]).to include(/Too many attempts/)
        expect(Rails.cache.read(rate_limiter_key)).to eq(4)
      end
    end

    context 'when admin_user is not found by token' do
      describe 'non-existing token' do
        it 'returns failure' do
          admin_user = create(:admin_user)
          _token = admin_user.generate_token!(:email_confirmation)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: 'xxxxxxxx')
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_email_confirmation_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        end
      end

      describe 'expired token' do
        it 'returns failure' do
          admin_user = create(:admin_user)
          token = admin_user.generate_token!(:email_confirmation, 0.seconds)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_email_confirmation_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Invalid or expired token/)
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        end
      end
    end

    context 'when admin_user is found by token' do
      context 'when email has already been confirmed' do
        it 'returns failure' do
          admin_user = create(:admin_user, email_confirmed_at: Time.current)
          token = admin_user.generate_token!(:email_confirmation)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_email_confirmation_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(email_confirmation_edit, request).call

          expect(result.failure?).to be(true)
          expect(result.errors[:base]).to include(/Email address has already been confirmed/)
          expect(result.data[:admin_user].email_confirmed_at).to be_present
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
        end
      end

      context 'when trying to confirm email raises an error' do
        it 'raises an error and uncalls rate_limiter' do
          admin_user = create(:admin_user)
          token = admin_user.generate_token!(:email_confirmation)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_email_confirmation_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)
          allow_any_instance_of(AdminUser).to receive(:confirm_email!).and_raise(ActiveRecord::ActiveRecordError)

          expect do
            described_class.new(email_confirmation_edit, request).call
          end.to raise_error(ActiveRecord::ActiveRecordError)

          expect(Rails.cache.read(rate_limiter_key)).to eq(0)
        end
      end

      context 'when trying to confirm email succeeds' do
        it 'returns success and expires tokens' do
          admin_user = create(:admin_user)
          token = admin_user.generate_token!(:email_confirmation)
          email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(token: token)
          request = TestRequestHelper.build(remote_ip: '1.1.1.1')
          rate_limiter_key = 'admin_users_email_confirmation_update:1.1.1.1'
          Rails.cache.write(rate_limiter_key, 0)

          result = described_class.new(email_confirmation_edit, request).call

          expect(result.success?).to be(true)
          expect(result.data[:admin_user].email_confirmed_at).to be_present
          expect(Rails.cache.read(rate_limiter_key)).to eq(1)
          expect(AdminUser.find_by_token(:email_confirmation, token)).to be_blank
        end
      end
    end
  end
end
