# frozen_string_literal: true

# == Schema Information
#
# Table name: sessions
#
#  id              :bigint           not null, primary key
#  expires_at      :datetime         not null
#  remote_ip       :string           not null
#  token_digest    :string           not null
#  token_last_four :string           not null
#  user_agent      :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_sessions_on_token_digest  (token_digest) UNIQUE
#  index_sessions_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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
