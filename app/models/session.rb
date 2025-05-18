class Session < ApplicationRecord
  belongs_to :user

  def self.find_by_token(token)
    return if token.blank?

    find_by(token_digest: TokenGenerator::Session.digest(token))
  end

  def expired?
    expires_at <= Time.current
  end
end
