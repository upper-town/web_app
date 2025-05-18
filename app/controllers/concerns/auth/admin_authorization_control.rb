module Auth
  module AdminAuthorizationControl
    class NotAuthorizedError < StandardError; end

    extend ActiveSupport::Concern

    included do
      rescue_from(NotAuthorizedError, with: :handle_admin_user_not_authorized)
    end

    def authorize_admin_user!(policy)
      raise NotAuthorizedError unless policy.allowed?
    end

    def handle_admin_user_not_authorized
      render("auth/forbidden", status: :forbidden)
    end
  end
end
