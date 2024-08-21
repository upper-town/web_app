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
class ServerAccount < ApplicationRecord
  belongs_to :server
  belongs_to :account

  def self.verified
    where.not(verified_at: nil)
  end

  def self.not_verified
    where(verified_at: nil)
  end

  def verified?
    verified_at.present?
  end

  def not_verified?
    !verified?
  end
end
