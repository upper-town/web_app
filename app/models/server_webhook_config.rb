# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_configs
#
#  id           :bigint           not null, primary key
#  disabled_at  :datetime
#  event_types  :string           default(["\"*\""]), not null, is an Array
#  notice       :string           default(""), not null
#  other_secret :string
#  secret       :string           not null
#  url          :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  server_id    :bigint           not null
#
# Indexes
#
#  index_server_webhook_configs_on_server_id  (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
class ServerWebhookConfig < ApplicationRecord
  belongs_to :server

  has_many :events, class_name: 'ServerWebhookEvent', dependent: :nullify

  encrypts :secret
  encrypts :other_secret

  normalizes :event_types, with: ->(list) do
    list.map { |str| str.downcase.delete('^[a-z_.*]') if str }.compact_blank
  end

  normalizes :secret, with: ->(str) { str.gsub(/[[:space:]]/, '') }
  normalizes :other_secret, with: ->(str) { str.gsub(/[[:space:]]/, '') }

  def self.enabled
    where(disabled_at: nil)
  end

  def self.disabled
    where.not(disabled_at: nil)
  end

  def self.for(server_id, event_type)
    enabled
      .where(server_id: server_id)
      .filter { |config| config.subscribed?(event_type) }
  end

  def enabled?
    disabled_at.nil?
  end

  def disabled?
    !enabled?
  end

  def subscribed?(event_type)
    event_types.any? { |event_type_pattern| File.fnmatch?(event_type_pattern, event_type) }
  end
end
