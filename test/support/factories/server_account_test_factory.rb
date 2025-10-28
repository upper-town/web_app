# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:server_account, ServerAccount,
  server: -> { build_server },
  account: -> { build_account }
)
