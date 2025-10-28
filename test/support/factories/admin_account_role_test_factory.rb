# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:admin_account_role, AdminAccountRole,
  admin_account: -> { build_admin_account },
  admin_role: -> { build_admin_role }
)
