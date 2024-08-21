# frozen_string_literal: true

module HasTokens
  TOKEN_EXPIRATION = 1.hour

  extend ActiveSupport::Concern

  class_methods do
    def token_generator
      TokenGenerator
    end

    def find_by_token(purpose, token)
      return if purpose.blank? || token.blank?

      joins(:tokens)
        .where(tokens: { purpose: purpose, token_digest: token_generator.digest(token) })
        .where('tokens.expires_at > ?', Time.current)
        .order(created_at: :desc)
        .first
    end
  end

  def regenerate_token!(purpose, expires_in = nil, data = {})
    expires_in ||= TOKEN_EXPIRATION

    token, token_digest, token_last_four = self.class.token_generator.generate

    tokens.create!(
      purpose: purpose,
      expires_at: expires_in.from_now,
      data: data,
      token_digest: token_digest,
      token_last_four: token_last_four,
    )

    token
  end
end
