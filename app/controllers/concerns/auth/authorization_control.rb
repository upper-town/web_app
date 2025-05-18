module Auth
  module AuthorizationControl
    class NotAuthorizedError < StandardError; end

    extend ActiveSupport::Concern

    included do
      rescue_from(NotAuthorizedError, with: :handle_user_not_authorized)
    end

    def authorize_user!(policy)
      raise NotAuthorizedError unless policy.allowed?
    end

    def handle_user_not_authorized
      render("auth/forbidden", status: :forbidden)
    end
  end
end
