# frozen_string_literal: true

require "test_helper"

class TokenGenerator::ApiSessionTest < ActiveSupport::TestCase
  let(:described_class) { TokenGenerator::ApiSession }
  let(:base58_chars) { "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789" }

  describe ".generate" do
    it "generates a random token and returns it with digest and last four" do
      secret = Rails.application.key_generator.generate_key(ENV.fetch("TOKEN_API_SESSION_SALT"))

      token, token_digest, token_last_four = described_class.generate
      assert_match(/\A[#{base58_chars}]{48}\z/, token)
      assert_equal(OpenSSL::HMAC.hexdigest("sha256", secret, token), token_digest)
      assert_equal(token.last(4), token_last_four)
    end
  end

  describe ".digest" do
    it "returns HMAC-signed digest of a token" do
      secret = Rails.application.key_generator.generate_key(ENV.fetch("TOKEN_API_SESSION_SALT"))
      token = "abcdef123456"
      expect_token_digest = OpenSSL::HMAC.hexdigest("sha256", secret, token)

      token_digest = described_class.digest(token)

      assert_equal(expect_token_digest, token_digest)
    end
  end
end
