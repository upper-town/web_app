# frozen_string_literal: true

# == Schema Information
#
# Table name: server_votes
#
#  id              :bigint           not null, primary key
#  country_code    :string           not null
#  metadata        :jsonb            not null
#  uuid            :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  app_id          :bigint           not null
#  server_id       :bigint           not null
#  user_account_id :bigint           not null
#
# Indexes
#
#  index_server_votes_on_app_id           (app_id)
#  index_server_votes_on_country_code     (country_code)
#  index_server_votes_on_server_id        (server_id)
#  index_server_votes_on_user_account_id  (user_account_id)
#  index_server_votes_on_uuid             (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_id => apps.id)
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class ServerVote < ApplicationRecord
  validates :country_code, inclusion: { in: Server::COUNTRY_CODES }

  belongs_to :user_account
  belongs_to :server
  belongs_to :app
end
