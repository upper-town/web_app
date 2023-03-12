# frozen_string_literal: true

# == Schema Information
#
# Table name: server_user_accounts
#
#  id              :bigint           not null, primary key
#  verified_at     :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  server_id       :bigint           not null
#  user_account_id :bigint           not null
#
# Indexes
#
#  index_server_user_accounts_on_server_id                      (server_id)
#  index_server_user_accounts_on_user_account_id_and_server_id  (user_account_id,server_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class ServerUserAccount < ApplicationRecord
  belongs_to :server
  belongs_to :user_account

  def self.verified
    where.not(verified_at: nil)
  end
end
