# frozen_string_literal: true

module Auth
  module TokenModel
    extend ActiveSupport::Concern

    class_methods do
      def expired
        where('expires_at <= ?', Time.current)
      end

      def not_expired
        where('expires_at > ?', Time.current)
      end

      def expire(values)
        where(value: values).update_all(expires_at: 1.day.ago)
      end
    end

    def expired?
      expires_at <= Time.current
    end

    def expire!
      update!(expires_at: 1.day.ago)
    end
  end
end
