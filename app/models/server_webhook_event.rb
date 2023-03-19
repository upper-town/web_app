# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_events
#
#  id              :bigint           not null, primary key
#  delivered_at    :datetime
#  failed_attempts :integer          default(0), not null
#  last_sent_at    :datetime
#  notice          :string           default(""), not null
#  payload         :jsonb            not null
#  status          :string           not null
#  type            :string           not null
#  uuid            :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  server_id       :bigint           not null
#
# Indexes
#
#  index_server_webhook_events_on_server_id  (server_id)
#  index_server_webhook_events_on_type       (type)
#  index_server_webhook_events_on_uuid       (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
class ServerWebhookEvent < ApplicationRecord
  include ShortUuidForModel

  PENDING   = 'pending'
  DELIVERED = 'delivered'
  RETRY     = 'retry'
  FAILED    = 'failed'

  STATUSES = [
    PENDING,
    DELIVERED,
    RETRY,
    FAILED
  ]

  SERVER_VOTES_CREATE = 'server_votes.create'

  TYPES = [
    SERVER_VOTES_CREATE,
  ]

  belongs_to :server
end
