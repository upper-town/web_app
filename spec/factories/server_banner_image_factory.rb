# frozen_string_literal: true

# == Schema Information
#
# Table name: server_banner_images
#
#  id           :bigint           not null, primary key
#  approved_at  :datetime
#  blob         :binary           not null
#  byte_size    :bigint           not null
#  checksum     :string           not null
#  content_type :string           not null
#  metadata     :jsonb            not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  server_id    :bigint           not null
#
# Indexes
#
#  index_server_banner_images_on_server_id  (server_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#
FactoryBot.define do
  factory :server_banner_image do
    server

    content_type { 'image/png' }
    blob { '' }
    byte_size { 0 }
    checksum { '' }
  end
end
