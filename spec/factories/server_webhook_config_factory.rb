# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_configs
#
#  id           :bigint           not null, primary key
#  disabled_at  :datetime
#  event_types  :string           default(["\"*\""]), not null, is an Array
#  method       :string           default("POST"), not null
#  notice       :string           default(""), not null
#  other_secret :string
#  secret       :string           not null
#  url          :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  server_id    :bigint           not null
#
# Indexes
#
#  index_server_webhook_configs_on_server_id  (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
FactoryBot.define do
  factory :server_webhook_config do
    server

    url { 'https://game.company.com' }
    secret { 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' }
  end
end
