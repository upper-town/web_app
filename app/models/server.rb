# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id                     :bigint           not null, primary key
#  archived_at            :datetime
#  country_code           :string           not null
#  description            :string           default(""), not null
#  info                   :text             default(""), not null
#  marked_for_deletion_at :datetime
#  name                   :string           not null
#  site_url               :string           not null
#  verified_at            :datetime
#  verified_notice        :text             default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  app_id                 :bigint           not null
#
# Indexes
#
#  index_servers_on_app_id                  (app_id)
#  index_servers_on_archived_at             (archived_at)
#  index_servers_on_country_code            (country_code)
#  index_servers_on_marked_for_deletion_at  (marked_for_deletion_at)
#  index_servers_on_name                    (name)
#  index_servers_on_verified_at             (verified_at)
#
# Foreign Keys
#
#  fk_rails_...  (app_id => apps.id)
#
class Server < ApplicationRecord
  COUNTRY_CODES = ISO3166::Country.codes

  normalizes :name, with: ->(str) { str.squish }
  normalizes :description, with: ->(str) { str.squish }
  normalizes :info, with: ->(str) { str.squish }

  validate :verified_server_with_same_name_exist?

  validates(
    :app_id,
    :name,
    :country_code,
    :site_url,
    presence: true
  )
  validates :country_code, inclusion: { in: COUNTRY_CODES }
  validates :name, length: { minimum: 3, maximum: 255 }
  validates :site_url, length: { minimum: 3, maximum: 255 }
  validates :description, length: { maximum: 1_000 }
  validates :info, length: { maximum: 1_000 }

  belongs_to :app

  has_one :banner_image, class_name: 'ServerBannerImage', dependent: :destroy

  has_many :votes, class_name: 'ServerVote', dependent: :destroy
  has_many :stats, class_name: 'ServerStat', dependent: :destroy

  has_many :server_user_accounts, dependent: :destroy
  has_many :user_accounts, through: :server_user_accounts

  has_many :webhook_configs, class_name: 'ServerWebhookConfig', dependent: :destroy
  has_many :webhook_secrets, class_name: 'ServerWebhookSecret', dependent: :destroy
  has_many :webhook_events,  class_name: 'ServerWebhookEvent',  dependent: :destroy

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
    archived_at
  end

  def not_archived?
    !archived?
  end

  def marked_for_deletion?
    marked_for_deletion_at
  end

  def not_marked_for_deletion?
    !marked_for_deletion?
  end

  def verified?
    verified_at
  end

  def not_verified?
    !verified?
  end

  def verified_user_accounts
    UserAccount
      .joins(:server_user_accounts)
      .where(server_user_accounts: { server_id: id })
      .where.not(server_user_accounts: { verified_at: nil })
  end

  def integrated?
    webhook_config?(ServerWebhookEvent::SERVER_VOTES_CREATE)
  end

  def webhook_config(event_type)
    webhook_configs.enabled.find_by(event_type: event_type)
  end

  def webhook_config?(event_type)
    webhook_configs.enabled.exists?(event_type: event_type)
  end

  def verified_server_with_same_name_exist?
    if Server.verified.exists?(name: name, app_id: app_id)
      errors.add(
        :name,
        'There is already a verified server with same name for this app. You can try to rename yours.'
      )
    end
  end
end
