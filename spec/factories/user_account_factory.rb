# frozen_string_literal: true

# == Schema Information
#
# Table name: user_accounts
#
#  id         :bigint           not null, primary key
#  uuid       :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_accounts_on_user_id  (user_id) UNIQUE
#  index_user_accounts_on_uuid     (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :user_account do
    uuid { SecureRandom.uuid }
    user
  end
end
