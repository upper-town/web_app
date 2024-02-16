# frozen_string_literal: true

# == Schema Information
#
# Table name: user_active_sessions
#
#  id         :bigint           not null, primary key
#  expires_at :datetime         not null
#  remote_ip  :string           not null
#  user_agent :string           default(""), not null
#  uuid       :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_active_sessions_on_user_id  (user_id)
#  index_user_active_sessions_on_uuid     (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserActiveSession < ApplicationRecord
  include Auth::ActiveSessionModel

  belongs_to :user

  alias_attribute :model, :user
end
