# frozen_string_literal: true

module Auth
  module AuthorizationControl
    class NotAuthorizedError < StandardError; end

    def self.[](auth_model)
      Module.new do
        extend ActiveSupport::Concern

        included do
          cattr_reader(:auth_model_sym, default: auth_model.name.underscore.to_sym)

          alias_method :"authorize_#{auth_model_sym}!", :authorize_model!

          rescue_from(NotAuthorizedError, with: :handle_not_authorized)
        end

        def authorize_model!(policy)
          raise NotAuthorizedError unless policy.allowed?
        end

        def handle_not_authorized
          render('auth/forbidden', status: :forbidden)
        end
      end
    end
  end
end
