# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:admin_account, AdminAccount,
  admin_user: -> { build_admin_user }
)
