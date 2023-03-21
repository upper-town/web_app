# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_configs
#
#  id          :bigint           not null, primary key
#  disabled_at :datetime
#  event_type  :string           not null
#  notice      :string           default(""), not null
#  url         :string           default(""), not null
#  uuid        :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  server_id   :bigint           not null
#
# Indexes
#
#  index_server_webhook_configs_on_server_id_and_event_type  (server_id,event_type) UNIQUE
#  index_server_webhook_configs_on_uuid                      (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
FactoryBot.define do
  factory :server_webhook_config do
    server

    uuid { SecureRandom.uuid }
    event_type { 'test.event_type' }
  end
end
