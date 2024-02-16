# frozen_string_literal: true

module Auth
  module AuthenticationControl
    class NotAuthenticatedError < StandardError; end
    class ExpiredActiveSessionError < StandardError; end
    class UnconfirmedError < StandardError; end
    class LockedError < StandardError; end

    # rubocop:disable Metrics/AbcSize
    def self.[](auth_model)
      Module.new do
        extend ActiveSupport::Concern

        include ManageActiveSession[auth_model]
        include ManageReturnTo

        def auth_root_path
          raise NotImplementedError
        end

        def auth_sign_in_path
          raise NotImplementedError
        end

        def auth_sign_out_path
          raise NotImplementedError
        end

        def auth_sign_up_path(...)
          raise NotImplementedError
        end

        included do
          cattr_reader(:auth_model_sym, default: auth_model.name.underscore.to_sym)

          alias_method :"current_#{auth_model_sym}_active_session", :current_model_active_session
          alias_method :"current_#{auth_model_sym}",                :current_model
          alias_method :"current_#{auth_model_sym}_account",        :current_model_account

          alias_method :"authenticate_#{auth_model_sym}!", :authenticate_model!

          before_action(
            :current_model_active_session,
            :current_model,
            :current_model_account
          )
          helper_method(
            :"current_#{auth_model_sym}_active_session",
            :"current_#{auth_model_sym}",
            :"current_#{auth_model_sym}_account",
            :signed_in?,
            :signed_out?
          )

          rescue_from(NotAuthenticatedError, with: :handle_not_authenticated)
          rescue_from(ExpiredActiveSessionError, with: :handle_expired_active_session)
          rescue_from(UnconfirmedError, with: :handle_unconfirmed)
          rescue_from(LockedError, with: :handle_locked)
        end

        def ignored_return_to_paths
          [auth_sign_out_path]
        end

        def authenticate_model!
          if !current_model_active_session
            raise NotAuthenticatedError
          end

          if current_model_active_session.expired?
            current_model_active_session.destroy!

            raise ExpiredActiveSessionError
          end

          if current_model.unconfirmed? && request.path != auth_sign_out_path
            raise UnconfirmedError
          end

          if current_model.locked? && request.path != auth_sign_out_path
            raise LockedError
          end
        end

        def handle_not_authenticated
          create_return_to

          redirect_to(
            auth_sign_in_path,
            info: 'You need to sign in to access this page.'
          )
        end

        def handle_expired_active_session
          create_return_to

          redirect_to(
            auth_sign_in_path,
            info: 'Your session has expired. Please sign in again.'
          )
        end

        def handle_unconfirmed
          redirect_to(
            auth_sign_up_path(email: current_model.email),
            info: 'You need to confirm your email address.'
          )
        end

        def handle_locked
          redirect_to(
            auth_root_path,
            info: 'Your account has been locked.'
          )
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
