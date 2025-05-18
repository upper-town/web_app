module Admin
  class AccessPolicy
    attr_reader :admin_account, :admin_permission_key

    def initialize(admin_account, admin_permission_key)
      @admin_account = admin_account
      @admin_permission_key = admin_permission_key
    end

    def allowed?
      return false unless admin_account
      return true if admin_account.super_admin?

      admin_account.permissions.exists?(key: admin_permission_key)
    end
  end
end
