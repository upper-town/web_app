# frozen_string_literal: true

class WebhookBatch < ApplicationRecord
  PENDING   = "pending"
  QUEUED    = "queued"
  DELIVERED = "delivered"
  FAILED    = "failed"

  STATUSES = [
    PENDING,
    QUEUED,
    DELIVERED,
    FAILED
  ]

  belongs_to(
    :config,
    class_name: "WebhookConfig",
    foreign_key: :webhook_config_id,
    inverse_of: :batches
  )

  has_many :events,  class_name: "WebhookEvent", dependent: :destroy

  validates :status, inclusion: { in: STATUSES }, presence: true

  def self.pending
    where(status: PENDING)
  end

  def pending?
    status == PENDING
  end

  def queued?
    status == QUEUED
  end

  def delivered?
    status == DELIVERED
  end

  def failed?
    status == FAILED
  end

  def delivered!(metadata = {})
    update!(
      status: DELIVERED,
      metadata: self.metadata.merge(metadata)
    )
  end

  def not_delivered!(metadata = {})
    self.failed_attempts += 1

    update!(
      status: failed_attempts > ApplicationJob::MAX_ATTEMPTS ? FAILED : status,
      failed_attempts:,
      metadata: self.metadata.merge(metadata)
    )
  end
end
