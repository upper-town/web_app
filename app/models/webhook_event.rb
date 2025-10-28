# frozen_string_literal: true

class WebhookEvent < ApplicationRecord
  SERVER_VOTE_CREATED = "server_vote.created"

  TYPES = [
    SERVER_VOTE_CREATED
  ]

  belongs_to(
    :config,
    class_name: "WebhookConfig",
    foreign_key: :webhook_config_id,
    inverse_of: :events
  )
  belongs_to(
    :batch,
    class_name: "WebhookBatch",
    foreign_key: :webhook_batch_id,
    inverse_of: :events,
    optional: true
  )

  validates :type, inclusion: { in: TYPES }, presence: true

  def self.unbatched
    where(webhook_batch_id: nil)
  end

  def source
    config.source
  end
end
