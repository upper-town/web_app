class ServerAccount < ApplicationRecord
  belongs_to :server
  belongs_to :account

  def self.verified
    where.not(verified_at: nil)
  end

  def self.not_verified
    where(verified_at: nil)
  end

  def verified?
    verified_at.present?
  end

  def not_verified?
    !verified?
  end
end
