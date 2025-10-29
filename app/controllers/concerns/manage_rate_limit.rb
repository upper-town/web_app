# frozen_string_literal: true

module ManageRateLimit
  extend ActiveSupport::Concern

  class_methods do
    def rate_limit(...)
      super unless rate_limit_disabled?
    end

    def rate_limit_disabled?
      Rails.env.local? && AppUtil.env_var_enabled?("RATE_LIMIT_DISABLED")
    end
  end

  private

  def render_rate_limited(view)
    flash.now[:alert] = t("shared.messages.please_try_again_later_too_many_requests")
    render(view, status: :too_many_requests)
  end
end
