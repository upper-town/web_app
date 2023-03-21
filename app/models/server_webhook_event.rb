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
#  index_server_webhook_events_on_uuid                      (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (server_webhook_config_id => server_webhook_configs.id)
#
class ServerWebhookEvent < ApplicationRecord
  include ShortUuidForModel

  MAX_FAILED_ATTEMPTS = 25

  PENDING   = 'pending'
  RETRY     = 'retry'
  DELIVERED = 'delivered'
  FAILED    = 'failed'

  STATUSES = [
    PENDING,
    RETRY,
    DELIVERED,
    FAILED
  ].freeze

  SERVER_VOTES_CREATE = 'server_votes.create'

  TYPES = [
    SERVER_VOTES_CREATE,
  ].freeze

  belongs_to :server
  belongs_to :config, class_name: 'ServerWebhookConfig', optional: true

  def pending?
    status == PENDING
  end

  def retry?
    status == RETRY
  end

  def delivered?
    status == DELIVERED
  end

  def failed?
    status == FAILED
  end

  def maxed_failed_attempts?
    failed_attempts >= MAX_FAILED_ATTEMPTS
  end

  def retry_in
    return unless retry?

    (failed_attempts**4) + 60 + (rand(10) * failed_attempts)
  end
end
