FactoryBot.define do
  factory :server_vote do
    uuid { SecureRandom.uuid }
    server
  end
end
