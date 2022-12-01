# frozen_string_literal: true

class HelloWorldJob
  include Sidekiq::Job

  def perform
    Rails.logger.info '[HelloWorldJob] Hello World!'
  end
end
