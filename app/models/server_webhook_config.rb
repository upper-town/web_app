# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_configs
#
#  id          :bigint           not null, primary key
#  disabled_at :datetime
#  event_type  :string           not null
#  notice      :string           default(""), not null
#  url         :string           default(""), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  server_id   :bigint           not null
#
# Indexes
#
#  index_server_webhook_configs_on_server_id_and_event_type  (server_id,event_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
class ServerWebhookConfig < ApplicationRecord
  belongs_to :server

  has_many :events, class_name: 'ServerWebhookEvent', dependent: :nullify

  def self.enabled
    where(disabled_at: nil)
  end

  def self.disabled
    where.not(disabled_at: nil)
  end

  def enabled?
    disabled_at.nil?
  end

  def disabled?
    !enabled?
  end
end
