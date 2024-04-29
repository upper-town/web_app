# frozen_string_literal: true

# == Schema Information
#
# Table name: server_votes
#
#  id              :bigint           not null, primary key
#  country_code    :string           not null
#  reference       :string           default(""), not null
#  remote_ip       :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  app_id          :bigint           not null
#  server_id       :bigint           not null
#  user_account_id :bigint
#
# Indexes
#
#  index_server_votes_on_app_id_and_country_code  (app_id,country_code)
#  index_server_votes_on_created_at               (created_at)
#  index_server_votes_on_server_id                (server_id)
#  index_server_votes_on_user_account_id          (user_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (app_id => apps.id)
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
class ServerVote < ApplicationRecord
  validates :country_code, inclusion: { in: Server::COUNTRY_CODES }

  belongs_to :server
  belongs_to :app
  belongs_to :user_account, optional: true
end
