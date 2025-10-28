# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:admin_user, AdminUser,
  email: -> { "admin.user.#{SecureRandom.base58}@upper.town" },
  password: -> { "testpass" }
)
