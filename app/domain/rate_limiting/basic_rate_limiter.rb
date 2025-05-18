# frozen_string_literal: true

module RateLimiting
  class BasicRateLimiter
    attr_reader :key, :max_count, :expires_in, :error_message

    def initialize(key, max_count, expires_in, error_message = nil)
      @key = key
      @max_count = max_count
      @expires_in = expires_in.to_i
      @error_message = error_message
    end

    def call
      count = Rails.cache.increment(key, 1, expires_in: expires_in)

      if count && count > max_count
        Result.failure(build_error_message)
      else
        Result.success
      end
    end

    def uncall
      Rails.cache.decrement(key, 1, expires_in: expires_in)

      Result.success
    end

    private

    def build_error_message
      try_again_message = "Please try again later"

      if error_message.blank?
        try_again_message
      else
        separator = error_message.end_with?(".", "!", "?", ";") ? " " : ". "

        "#{error_message}#{separator}#{try_again_message}"
      end
    end
  end
end
