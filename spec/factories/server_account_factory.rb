# frozen_string_literal: true

# == Schema Information
#
# Table name: server_accounts
#
#  id          :bigint           not null, primary key
#  verified_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint           not null
#  server_id   :bigint           not null
#
# Indexes
#
#  index_server_accounts_on_account_id_and_server_id  (account_id,server_id) UNIQUE
#  index_server_accounts_on_server_id                 (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (server_id => servers.id)
#
FactoryBot.define do
  factory :server_account do
    server
    account
  end
end
