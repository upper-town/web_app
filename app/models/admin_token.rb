# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_tokens
#
#  id              :bigint           not null, primary key
#  data            :jsonb            not null
#  expires_at      :datetime         not null
#  purpose         :string           not null
#  token_digest    :string           not null
#  token_last_four :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin_user_id   :bigint           not null
#
# Indexes
#
#  index_admin_tokens_on_admin_user_id  (admin_user_id)
#  index_admin_tokens_on_expires_at     (expires_at)
#  index_admin_tokens_on_purpose        (purpose)
#  index_admin_tokens_on_token_digest   (token_digest) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
class AdminToken < ApplicationRecord
  belongs_to :admin_user

  def self.find_by_token(token)
    return if token.blank?

    find_by(token_digest: TokenGenerator::Admin.digest(token))
  end

  def self.expired
    where('expires_at <= ?', Time.current)
  end

  def self.not_expired
    where('expires_at > ?', Time.current)
  end

  def self.expire(tokens)
    where(token: tokens).update_all(expires_at: 1.day.ago)
  end

  def expired?
    expires_at <= Time.current
  end

  def expire!
    update!(expires_at: 1.day.ago)
  end
end
