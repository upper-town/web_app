# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_sessions
#
#  id              :bigint           not null, primary key
#  expires_at      :datetime         not null
#  remote_ip       :string           not null
#  token_digest    :string           not null
#  token_last_four :string           not null
#  user_agent      :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin_user_id   :bigint           not null
#
# Indexes
#
#  index_admin_sessions_on_admin_user_id  (admin_user_id)
#  index_admin_sessions_on_token_digest   (token_digest) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
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
