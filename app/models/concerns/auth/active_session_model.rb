# frozen_string_literal: true

module Auth
  module ActiveSessionModel
    extend ActiveSupport::Concern

    def expired?
      expires_at <= Time.current
    end
  end
end
