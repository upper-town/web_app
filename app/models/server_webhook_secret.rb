# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_secrets
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  uuid        :uuid             not null
#  value       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  server_id   :bigint           not null
#
# Indexes
#
#  index_server_webhook_secrets_on_server_id  (server_id)
#  index_server_webhook_secrets_on_uuid       (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
class ServerWebhookSecret < ApplicationRecord
  belongs_to :server

  def self.active
    where(archived_at: nil)
  end

  def self.archived
    where.not(archived_at: nil)
  end
end
