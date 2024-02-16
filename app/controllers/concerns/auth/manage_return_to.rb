# frozen_string_literal: true

module Auth
  module ManageReturnTo
    include CookieJsonValue

    def ignored_return_to_paths
      raise NotImplementedError
    end

    RETURN_TO = 'return_to'

    def create_return_to(duration = 3.minutes)
      return if ignored_return_to_paths.include?(request.path)
      return unless request.get?

      return_to = ReturnTo.new(url: request.original_url, expires_at: duration.from_now)
      write_cookie_json_value(RETURN_TO, return_to)
    end

    def consume_return_to
      attributes = parse_cookie_json_value(RETURN_TO)
      return_to = ReturnTo.new(attributes)

      request.cookie_jar.delete(RETURN_TO)

      return_to.url unless return_to.expired?
    end

    class ReturnTo < ApplicationForm
      attribute :url, :string
      attribute :expires_at, :datetime, default: nil

      def expired?
        expires_at.blank? || expires_at <= Time.current
      end
    end
  end
end
