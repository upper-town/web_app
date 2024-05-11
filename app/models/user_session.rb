# frozen_string_literal: true

# == Schema Information
#
# Table name: user_sessions
#
#  id         :bigint           not null, primary key
#  expires_at :datetime         not null
#  remote_ip  :string           not null
#  token      :string           not null
#  user_agent :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_sessions_on_token    (token) UNIQUE
#  index_user_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserSession < ApplicationRecord
  belongs_to :user

  def expired?
    expires_at <= Time.current
  end
end
