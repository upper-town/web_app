# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_configs
#
#  id          :bigint           not null, primary key
#  disabled_at :datetime
#  event_type  :string           not null
#  notice      :string           not null
#  status      :string           not null
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
class ServerWebhookConfig < ApplicationRecord
  include ShortUuidForModel

  belongs_to :server

  def self.enabled
    where(disabled_at: nil)
  end
end
