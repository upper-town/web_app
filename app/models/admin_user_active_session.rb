# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_user_active_sessions
#
#  id            :bigint           not null, primary key
#  expires_at    :datetime         not null
#  remote_ip     :string           not null
#  token         :string           not null
#  user_agent    :string           default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_user_id :bigint           not null
#
# Indexes
#
#  index_admin_user_active_sessions_on_admin_user_id  (admin_user_id)
#  index_admin_user_active_sessions_on_token          (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
class AdminUserActiveSession < ApplicationRecord
  belongs_to :admin_user

  alias_attribute :model, :admin_user

  def expired?
    expires_at <= Time.current
  end
end
