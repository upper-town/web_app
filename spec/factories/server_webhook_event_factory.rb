# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_events
#
#  id                       :bigint           not null, primary key
#  delivered_at             :datetime
#  failed_attempts          :integer          default(0), not null
#  last_published_at        :datetime
#  notice                   :string           default(""), not null
#  payload                  :jsonb            not null
#  status                   :string           not null
#  type                     :string           not null
#  uuid                     :uuid             not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  server_id                :bigint           not null
#  server_webhook_config_id :bigint
#
# Indexes
#
#  index_server_webhook_events_on_server_id                 (server_id)
#  index_server_webhook_events_on_server_webhook_config_id  (server_webhook_config_id)
#  index_server_webhook_events_on_type                      (type)
#  index_server_webhook_events_on_updated_at                (updated_at)
#  index_server_webhook_events_on_uuid                      (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (server_webhook_config_id => server_webhook_configs.id)
#
FactoryBot.define do
  factory :server_webhook_event do
    server

    payload { {} }
    status { ServerWebhookEvent::PENDING }
    type { 'test.event' }
  end
end
