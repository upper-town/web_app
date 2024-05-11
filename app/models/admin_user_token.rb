# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_user_tokens
#
#  id            :bigint           not null, primary key
#  data          :jsonb            not null
#  expires_at    :datetime         not null
#  purpose       :string           not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_user_id :bigint           not null
#
# Indexes
#
#  index_admin_user_tokens_on_admin_user_id  (admin_user_id)
#  index_admin_user_tokens_on_expires_at     (expires_at)
#  index_admin_user_tokens_on_purpose        (purpose)
#  index_admin_user_tokens_on_token          (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
class AdminUserToken < ApplicationRecord
  belongs_to :admin_user

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
