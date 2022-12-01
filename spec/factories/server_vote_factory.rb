# frozen_string_literal: true

FactoryBot.define do
  factory :server_vote do
    uuid { SecureRandom.uuid }
    server
  end
end
