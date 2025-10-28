# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:admin_role_permission, AdminRolePermission,
  admin_role: -> { build_admin_role },
  admin_permission: -> { build_admin_permission }
)
