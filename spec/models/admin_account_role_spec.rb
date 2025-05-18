require 'rails_helper'

RSpec.describe AdminAccountRole do
  describe 'associations' do
    it 'belongs to admin_account' do
      admin_account_role = create(:admin_account_role)

      expect(admin_account_role.admin_account).to be_present
    end

    it 'belongs to admin_role' do
      admin_account_role = create(:admin_account_role)

      expect(admin_account_role.admin_role).to be_present
    end
  end

  describe 'validations' do
    it 'validates admin_role_id scoped to admin_account_id' do
      admin_account = create(:admin_account)
      admin_role = create(:admin_role)
      existing_admin_account_role = create(
        :admin_account_role,
        admin_account: admin_account,
        admin_role: admin_role
      )
      admin_account_role = build(
        :admin_account_role,
        admin_account: admin_account,
        admin_role: admin_role
      )

      admin_account_role.validate

      expect(admin_account_role.errors.of_kind?(:admin_role_id, :taken)).to be(true)

      existing_admin_account_role.destroy!
      admin_account_role.validate

      expect(admin_account_role.errors.key?(:admin_role_id)).to be(false)
    end
  end
end
