# frozen_string_literal: true

ApplicationRecordTestFactoryHelper.define(:token, Token,
  user: -> { build_user },
  purpose: -> { "email_confirmation" },
  expires_at: -> { 30.days.from_now },
  token_last_four: -> { "abcd" },
  token_digest: ->(attributes) { Digest::SHA256.hexdigest("token-#{SecureRandom.base58}-#{attributes[:token_last_four]}") }
)
