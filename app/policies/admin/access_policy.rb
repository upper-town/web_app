# frozen_string_literal: true

module Admin
  class AccessPolicy
    attr_reader :admin_user, :admin_permission_key

    def initialize(admin_user, admin_permission_key)
      @admin_user = admin_user
      @admin_permission_key = admin_permission_key
    end

    def allowed?
      return false unless admin_user
      return true if admin_user.super_admin?

      admin_user.permissions.exists?(key: admin_permission_key)
    end
  end
end
