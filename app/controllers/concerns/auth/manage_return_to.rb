# frozen_string_literal: true

module Auth
  module ManageReturnTo
    include JsonCookie

    def ignored_return_to_paths
      raise NotImplementedError
    end

    RETURN_TO_NAME = "return_to"

    def write_return_to(duration = 3.minutes)
      return unless request.get? || request.head?
      return if ignored_return_to_paths.include?(request.path)

      write_json_cookie(
        RETURN_TO_NAME,
        ReturnTo.new(url: request.original_url, expires_at: duration.from_now)
      )
    end

    def consume_return_to
      return_to = ReturnTo.new(read_json_cookie(RETURN_TO_NAME))
      delete_json_cookie(RETURN_TO_NAME)

      return_to.url.presence unless return_to.expired?
    end

    class ReturnTo < ApplicationModel
      attribute :url, :string, default: nil
      attribute :expires_at, :datetime, default: nil

      def expired?
        expires_at.blank? || expires_at <= Time.current
      end
    end
  end
end
