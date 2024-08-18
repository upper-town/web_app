# frozen_string_literal: true

FactoryBot.define do
  factory :server_banner_image do
    server

    content_type { 'image/png' }
    blob { '' }
    byte_size { 0 }
    checksum { '' }
  end
end
