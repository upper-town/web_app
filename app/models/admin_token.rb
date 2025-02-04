# frozen_string_literal: true

class AdminToken < ApplicationRecord
  belongs_to :admin_user

  def self.find_by_token(token, include_expired = false)
    return if token.blank?

    if include_expired
      find_by(token_digest: TokenGenerator::Admin.digest(token))
    else
      not_expired.where(token_digest: TokenGenerator::Admin.digest(token)).first
    end
  end

  def self.expired
    where(expires_at: ..Time.current)
  end

  def self.not_expired
    where('expires_at > ?', Time.current)
  end

  def expired?
    expires_at <= Time.current
  end

  def expire!
    update!(expires_at: 1.day.ago)
  end
end
