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
  include Auth::TokenModel

  belongs_to :user
end
