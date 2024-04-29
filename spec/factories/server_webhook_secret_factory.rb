# frozen_string_literal: true

# == Schema Information
#
# Table name: server_webhook_secrets
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  value       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  server_id   :bigint           not null
#
# Indexes
#
#  index_server_webhook_secrets_on_server_id  (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
FactoryBot.define do
  factory :server_webhook_secret do
    server

    value { 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' }
  end
end
