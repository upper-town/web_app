# frozen_string_literal: true

class Server < ApplicationRecord
  COUNTRY_CODES = ISO3166::Country.codes

  belongs_to :game

  has_one :banner_image, class_name: "ServerBannerImage", dependent: :destroy

  has_many :votes, class_name: "ServerVote", dependent: :destroy
  has_many :stats, class_name: "ServerStat", dependent: :destroy

  has_many :server_accounts, dependent: :destroy
  has_many :accounts, through: :server_accounts
  has_many :verified_accounts,
    -> { where.not(server_accounts: { verified_at: nil }) },
    through: :server_accounts,
    source: :account

  has_many :webhook_configs, class_name: "ServerWebhookConfig", dependent: :destroy
  has_many :webhook_events,  class_name: "ServerWebhookEvent",  dependent: :destroy

  normalizes :name, with: ->(str) { str.squish }
  normalizes :description, with: ->(str) { str.squish }
  normalizes :info, with: ->(str) { str.strip }

  validates :name, length: { minimum: 3, maximum: 255 }, presence: true
  validates :description, length: { maximum: 1_000 }
  validates :info, length: { maximum: 1_000 }
  validates :country_code, inclusion: { in: COUNTRY_CODES }, presence: true
  validates :site_url, presence: true, length: { minimum: 3, maximum: 255 }, site_url: true

  validate :verified_server_with_same_name_exist

  def self.archived
    where.not(archived_at: nil)
  end

  def self.not_archived
    where(archived_at: nil)
  end

  def self.marked_for_deletion
    where.not(marked_for_deletion_at: nil)
  end

  def self.not_marked_for_deletion
    where(marked_for_deletion_at: nil)
  end

  def self.verified
    where.not(verified_at: nil)
  end

  def self.not_verified
    where(verified_at: nil)
  end

  def archived?
    archived_at.present?
  end

  def not_archived?
    !archived?
  end

  def marked_for_deletion?
    marked_for_deletion_at.present?
  end

  def not_marked_for_deletion?
    !marked_for_deletion?
  end

  def verified?
    verified_at.present?
  end

  def not_verified?
    !verified?
  end

  def webhook_config(event_type)
    webhook_configs.enabled.find do |webhook_config|
      webhook_config.subscribed?(event_type)
    end
  end

  def webhook_config?(event_type)
    webhook_configs.enabled.any? do |webhook_config|
      webhook_config.subscribed?(event_type)
    end
  end

  def integrated?
    webhook_config?(ServerWebhookEvent::SERVER_VOTE_CREATED)
  end

  private

  def verified_server_with_same_name_exist
    return if not_verified?

    if Server.verified.exists?(name: name, game_id: game_id)
      errors.add(:name, :verified_server_with_same_name_exist)
    end
  end
end
