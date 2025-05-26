# frozen_string_literal: true

class Code < ApplicationRecord
  belongs_to :user

  def self.find_by_code(code, include_expired = false)
    return if code.blank?

    if include_expired
      find_by(code_digest: CodeGenerator.digest(code))
    else
      not_expired.where(code_digest: CodeGenerator.digest(code)).first
    end
  end

  def self.expired
    where(expires_at: ..Time.current)
  end

  def self.not_expired
    where("expires_at > ?", Time.current)
  end

  def expired?
    expires_at <= Time.current
  end

  def expire!
    update!(expires_at: 1.day.ago)
  end
end
