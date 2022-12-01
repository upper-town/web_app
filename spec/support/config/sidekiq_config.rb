# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    Sidekiq::Queues.clear_all
  end
end
