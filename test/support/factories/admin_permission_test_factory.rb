# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:admin_permission, AdminPermission,
  key: -> { "admin_permission_key_#{SecureRandom.base58}" },
  description: -> { "AdminPermission description" }
)
