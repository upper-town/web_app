# frozen_string_literal: true

# == Schema Information
#
# Table name: user_accounts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_accounts_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserAccount < ApplicationRecord
  belongs_to :user

  has_many :server_votes, dependent: :nullify
  has_many :server_user_accounts, dependent: :destroy
  has_many :servers, through: :server_user_accounts

  def verified_servers
    Server
      .joins(:server_user_accounts)
      .where(server_user_accounts: { user_account_id: id })
      .where.not(server_user_accounts: { verified_at: nil })
  end
end
