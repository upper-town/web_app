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
