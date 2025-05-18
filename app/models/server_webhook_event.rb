class ServerWebhookEvent < ApplicationRecord
  MAX_FAILED_ATTEMPTS = 25

  PENDING   = "pending"
  RETRY     = "retry"
  DELIVERED = "delivered"
  FAILED    = "failed"

  STATUSES = [
    PENDING,
    RETRY,
    DELIVERED,
    FAILED
  ]

  SERVER_VOTE_CREATED = "server_vote.created"

  TYPES = [
    SERVER_VOTE_CREATED
  ]

  belongs_to :server
  belongs_to(
    :config,
    class_name: "ServerWebhookConfig",
    foreign_key: :server_webhook_config_id,
    inverse_of: :events,
    optional: true
  )

  validates :status, inclusion: { in: STATUSES }, presence: true

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

    (failed_attempts**4) + 60 + (SecureRandom.rand(10) * failed_attempts)
  end
end
