# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id                     :bigint           not null, primary key
#  archived_at            :datetime
#  banner_image_url       :string           default(""), not null
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
FactoryBot.define do
  factory :server do
    app

    country_code { 'US' }
    sequence(:name) { |n| "Server #{n}" }
    sequence(:site_url) { |n| "https://server-#{n}.example.com/" }
  end
end
