FactoryBot.define do
  factory :server_webhook_config do
    server

    url { 'https://game.company.com' }
    secret { 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' }
  end
end
