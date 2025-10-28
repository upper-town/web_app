# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:account, Account,
  user: -> { build_user }
)
