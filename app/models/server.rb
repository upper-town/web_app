# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id                  :bigint           not null, primary key
#  banner_image_url    :string           default(""), not null
#  country_code        :string           not null
#  description         :string           default(""), not null
#  info                :text             default(""), not null
#  name                :string           not null
#  site_url            :string           not null
#  uuid                :uuid             not null
#  verified_notice     :text             default(""), not null
#  verified_status     :string           default("pending"), not null
#  verified_updated_at :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  app_id              :bigint           not null
#
# Indexes
#
#  index_servers_on_app_id        (app_id)
#  index_servers_on_country_code  (country_code)
#  index_servers_on_name          (name)
#  index_servers_on_uuid          (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_id => apps.id)
#
class Server < ApplicationRecord
  include ShortUuidForModel

  PENDING = 'pending'
  VERIFIED = 'verified'

  VERIFIED_STATUSES = [PENDING, VERIFIED].freeze

  COUNTRY_CODES = ISO3166::Country.codes

  validate :verified_server_with_same_name_exist?

  validates :country_code,    inclusion: { in: COUNTRY_CODES }
  validates :verified_status, inclusion: { in: VERIFIED_STATUSES }
  validates :name,     length: { minimum: 3, maximum: 255 }
  validates :site_url, length: { minimum: 3, maximum: 255 }

  belongs_to :app

  has_many :votes, class_name: 'ServerVote', dependent: :destroy
  has_many :stats, class_name: 'ServerStat', dependent: :destroy

  has_many :server_user_accounts, dependent: :destroy
  has_many :user_accounts, through: :server_user_accounts

  has_many :webhook_configs, class_name: 'ServerWebhookConfig', dependent: :destroy
  has_many :webhook_secrets, class_name: 'ServerWebhookSecret', dependent: :destroy
  has_many :webhook_events,  class_name: 'ServerWebhookEvent',  dependent: :destroy

  def verified_user_accounts
    UserAccount
      .joins(:server_user_accounts)
      .where(server_user_accounts: { server_id: id })
      .where.not(server_user_accounts: { verified_at: nil })
  end

  def verified?
    verified_status == VERIFIED
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
    if Server.exists?(verified_status: VERIFIED, name: name, app_id: app_id)
      errors.add(
        :name,
        "There is already a verified server with same name for this app. You can try to rename yours."
      )
    end
  end
end
