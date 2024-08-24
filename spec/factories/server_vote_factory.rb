# frozen_string_literal: true

# == Schema Information
#
# Table name: server_votes
#
#  id           :bigint           not null, primary key
#  country_code :string           not null
#  reference    :string           default(""), not null
#  remote_ip    :string           default(""), not null
#  uuid         :uuid             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint
#  game_id      :bigint           not null
#  server_id    :bigint           not null
#
# Indexes
#
#  index_server_votes_on_account_id                (account_id)
#  index_server_votes_on_created_at                (created_at)
#  index_server_votes_on_game_id_and_country_code  (game_id,country_code)
#  index_server_votes_on_server_id                 (server_id)
#  index_server_votes_on_uuid                      (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (server_id => servers.id)
#
FactoryBot.define do
  factory :server_vote do
    server
    game

    country_code { 'US' }
  end
end
