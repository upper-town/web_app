# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_user_tokens
#
#  id            :bigint           not null, primary key
#  data          :jsonb            not null
#  expires_at    :datetime         not null
#  purpose       :string           not null
#  value         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_user_id :bigint           not null
#
# Indexes
#
#  index_admin_user_tokens_on_admin_user_id  (admin_user_id)
#  index_admin_user_tokens_on_expires_at     (expires_at)
#  index_admin_user_tokens_on_purpose        (purpose)
#  index_admin_user_tokens_on_value          (value) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_user_id => admin_users.id)
#
class AdminUserToken < ApplicationRecord
  include Auth::TokenModel

  belongs_to :admin_user
end
