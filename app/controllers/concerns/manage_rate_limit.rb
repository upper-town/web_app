# frozen_string_literal: true

module ManageRateLimit
  extend ActiveSupport::Concern

  module ClassMethods
    def rate_limit(...)
      super(...) unless rate_limit_disabled?
    end

    def rate_limit_disabled?
      Rails.env.local? && ENV.fetch("RATE_LIMIT_DISABLED", "false") == "true"
    end
  end
end
