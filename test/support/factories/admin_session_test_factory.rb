# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:admin_session, AdminSession,
  admin_user: -> { build_admin_user },
  token_last_four: -> { "abcd" },
  token_digest: ->(attributes) { Digest::SHA256.hexdigest("admin-token-#{SecureRandom.base58}-#{attributes[:token_last_four]}") },
  expires_at: -> { 30.days.from_now },
  remote_ip: -> { "255.255.255.255" }
)
