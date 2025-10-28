# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:user, User,
  email: -> { "user_#{SecureRandom.base58}@upper.town" },
  password: -> { "testpass" }
)
