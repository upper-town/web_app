# frozen_string_literal: true

module RateLimiting
  class BasicRateLimiter
    attr_reader :key, :max_count, :expires_in, :error_message

    def initialize(key, max_count, expires_in, error_message = '')
      @key = key
      @max_count = max_count
      @expires_in = expires_in.to_i
      @error_message = error_message
    end

    def call
      replies = RateLimiting.redis.multi do |transaction|
        transaction.incr(key)
        transaction.expire(key, expires_in, nx: true)
        transaction.ttl(key)
      end

      if replies[0] <= max_count
        Result.success
      else
        Result.failure(build_error_message(replies[2]))
      end
    end

    def uncall
      RateLimiting.redis.multi do |transaction|
        transaction.decr(key)
        transaction.expire(key, expires_in, nx: true)
      end

      Result.success
    end

    private

    def build_error_message(ttl_seconds)
      if error_message.blank?
        try_again_message(ttl_seconds)
      else
        separator = error_message.end_with?('.', '!', '?') ? ' ' : '. '

        "#{error_message}#{separator}#{try_again_message(ttl_seconds)}"
      end
    end

    def try_again_message(ttl_seconds)
      "Please try again in #{ttl_to_sentence(ttl_seconds)}"
    end

    def ttl_to_sentence(seconds)
      ActiveSupport::Duration.build(seconds).inspect
    end
  end
end
