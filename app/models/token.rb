# frozen_string_literal: true

# == Schema Information
#
# Table name: tokens
#
#  id              :bigint           not null, primary key
#  data            :jsonb            not null
#  expires_at      :datetime         not null
#  purpose         :string           not null
#  token_digest    :string           not null
#  token_last_four :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_tokens_on_expires_at    (expires_at)
#  index_tokens_on_purpose       (purpose)
#  index_tokens_on_token_digest  (token_digest) UNIQUE
#  index_tokens_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Token < ApplicationRecord
  belongs_to :user

  def self.find_by_token(token, include_expired = false)
    return if token.blank?

    if include_expired
      find_by(token_digest: TokenGenerator.digest(token))
    else
      not_expired.where(token_digest: TokenGenerator.digest(token)).first
    end
  end

  def self.expired
    where('expires_at <= ?', Time.current)
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
