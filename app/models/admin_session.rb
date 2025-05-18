class AdminSession < ApplicationRecord
  belongs_to :admin_user

  def self.find_by_token(token)
    return if token.blank?

    find_by(token_digest: TokenGenerator::AdminSession.digest(token))
  end

  def expired?
    expires_at <= Time.current
  end
end
