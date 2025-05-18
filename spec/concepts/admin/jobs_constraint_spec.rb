require 'rails_helper'

RSpec.describe Admin::JobsConstraint do
  describe '#matches?' do
    context 'when admin_user is signed_in' do
      context 'when admin_account has the jobs_access permission' do
        it 'returns true' do
          admin_account = create(:admin_account)
          admin_role = create(:admin_role, permissions: [ create(:admin_permission, key: 'jobs_access') ])
          create(:admin_account_role, admin_account: admin_account, admin_role: admin_role)
          request = build_request(admin_account.admin_user, signed_in: true)

          expect(described_class.new.matches?(request)).to be(true)
        end
      end

      context 'when admin_account does not have the jobs_access permission' do
        it 'returns false' do
          admin_account = create(:admin_account)
          request = build_request(admin_account.admin_user, signed_in: true)

          expect(described_class.new.matches?(request)).to be(false)
        end
      end
    end

    context 'when admin_user is not signed_in' do
      it 'returns false' do
        admin_account = create(:admin_account)
        admin_role = create(:admin_role, permissions: [ create(:admin_permission, key: 'jobs_access') ])
        create(:admin_account_role, admin_account: admin_account, admin_role: admin_role)
        request = build_request(admin_account.admin_user, signed_in: false)

        expect(described_class.new.matches?(request)).to be(false)
      end
    end
  end

  def build_request(admin_user, signed_in:)
    request = TestRequestHelper.build

    if signed_in
      token, token_digest, token_last_four = TokenGenerator::AdminSession.generate
      create(
        :admin_session,
        admin_user: admin_user,
        token_digest: token_digest,
        token_last_four: token_last_four,
        expires_at: 1.month.from_now
      )
      request.cookie_jar['admin_session'] = { token: token }.to_json
    end

    request
  end
end
