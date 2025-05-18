# frozen_string_literal: true

module TokenGenerator
  SECRET = Rails.application.key_generator.generate_key(ENV.fetch("TOKEN_SALT"))

  extend self

  def generate(length = 48, secret = SECRET)
    token = SecureRandom.base58(length)
    token_digest = digest(token, secret)
    token_last_four = token.last(4)

    [token, token_digest, token_last_four]
  end

  def digest(token, secret = SECRET)
    OpenSSL::HMAC.hexdigest("sha256", secret, token)
  end
end
