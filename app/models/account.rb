# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id         :bigint           not null, primary key
#  uuid       :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_accounts_on_user_id  (user_id) UNIQUE
#  index_accounts_on_uuid     (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Account < ApplicationRecord
  belongs_to :user

  has_many :server_votes, dependent: :nullify
  has_many :server_accounts, dependent: :destroy
  has_many :servers, through: :server_accounts
  has_many(
    :verified_servers,
    -> { where.not(server_accounts: { verified_at: nil }) },
    through: :server_accounts,
    source: :server
  )
end
