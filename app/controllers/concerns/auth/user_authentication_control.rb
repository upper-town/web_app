# frozen_string_literal: true

module Auth
  module UserAuthenticationControl
    class NotAuthenticatedError < StandardError; end
    class ExpiredSessionError < StandardError; end
    class UnconfirmedEmailError < StandardError; end
    class LockedError < StandardError; end

    extend ActiveSupport::Concern

    include UserManageSession
    include ManageReturnTo

    included do
      before_action(
        :current_user_session,
        :current_user,
        :current_user_account
      )
      helper_method(
        :current_user_session,
        :current_user,
        :current_user_account,
        :signed_in_user?,
        :signed_out_user?
      )

      rescue_from(NotAuthenticatedError, with: :handle_user_not_authenticated)
      rescue_from(ExpiredSessionError, with: :handle_user_expired_session)
      rescue_from(UnconfirmedEmailError, with: :handle_user_unconfirmed_email)
      rescue_from(LockedError, with: :handle_user_locked)
    end

    def ignored_return_to_paths
      [users_sign_out_path]
    end

    def authenticate_user!
      if !current_user_session
        raise NotAuthenticatedError
      end

      if current_user_session.expired?
        current_user_session.destroy!

        raise ExpiredSessionError
      end

      if current_user.unconfirmed_email? && request.path != users_sign_out_path
        raise UnconfirmedEmailError
      end

      if current_user.locked? && request.path != users_sign_out_path
        raise LockedError
      end
    end

    def handle_user_not_authenticated
      create_return_to

      redirect_to(
        users_sign_in_path,
        info: 'You need to sign in to access this page.'
      )
    end

    def handle_user_expired_session
      create_return_to

      redirect_to(
        users_sign_in_path,
        info: 'Your session has expired. Please sign in again.'
      )
    end

    def handle_user_unconfirmed_email
      redirect_to(
        users_sign_up_path(email: current_user.email),
        info: 'You need to confirm your email address.'
      )
    end

    def handle_user_locked
      redirect_to(
        root_path,
        info: 'Your account has been locked.'
      )
    end
  end
end
