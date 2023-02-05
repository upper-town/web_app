# frozen_string_literal: true

# == Schema Information
#
# Table name: server_votes
#
#  id              :bigint           not null, primary key
#  country_code    :string           not null
#  metadata        :jsonb            not null
#  remote_ip       :string           default(""), not null
#  uuid            :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  app_id          :bigint           not null
#  reference_id    :string           default(""), not null
#  server_id       :bigint           not null
#  user_account_id :bigint
#
# Indexes
#
#  index_server_votes_on_app_id_and_country_code  (app_id,country_code)
#  index_server_votes_on_created_at               (created_at)
#  index_server_votes_on_server_id                (server_id)
#  index_server_votes_on_user_account_id          (user_account_id)
#  index_server_votes_on_uuid                     (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_id => apps.id)
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (user_account_id => user_accounts.id)
#
FactoryBot.define do
  factory :server_vote do
    uuid { SecureRandom.uuid }
    server
  end
end
