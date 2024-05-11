# frozen_string_literal: true

# == Schema Information
#
# Table name: user_tokens
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  expires_at :datetime         not null
#  purpose    :string           not null
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_tokens_on_expires_at  (expires_at)
#  index_user_tokens_on_purpose     (purpose)
#  index_user_tokens_on_token       (token) UNIQUE
#  index_user_tokens_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserToken < ApplicationRecord
  belongs_to :user

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
