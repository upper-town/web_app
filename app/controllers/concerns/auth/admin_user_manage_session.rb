# frozen_string_literal: true

module Auth
  module AdminUserManageSession
    ADMIN_USER_SESSION_COOKIE_NAME = 'admin_user_session'
    ADMIN_USER_SESSION_REMEMBER_ME_DURATION = 4.months
    ADMIN_USER_SESSION_TOKEN_LENGTH = 44

    extend ActiveSupport::Concern

    def current_admin_user_session
      Current.admin_user_session ||= find_admin_user_session(read_admin_user_session_cookie)
    end

    def current_admin_user
      Current.admin_user ||= current_admin_user_session&.admin_user
    end

    def current_admin_user_account
      Current.admin_user_account ||= current_admin_user&.account
    end

    def signed_in_admin_user?
      current_admin_user.present?
    end

    def signed_out_admin_user?
      !signed_in_admin_user?
    end

    def sign_in_admin_user!(admin_user, remember_me = false)
      admin_user_session = create_admin_user_session(admin_user, remember_me)
      store_admin_user_session_cookie(admin_user_session.token, remember_me)
    end

    def sign_out_admin_user!
      current_admin_user_session&.destroy!
      delete_admin_user_session_cookie
    end

    private

    def store_admin_user_session_cookie(token, remember_me)
      request.cookie_jar[ADMIN_USER_SESSION_COOKIE_NAME] = {
        value: token,
        expires: remember_me ? ADMIN_USER_SESSION_REMEMBER_ME_DURATION : nil,
        httponly: true,
        secure: Rails.env.production?
      }
    end

    def read_admin_user_session_cookie
      request.cookie_jar[ADMIN_USER_SESSION_COOKIE_NAME]
    end

    def delete_admin_user_session_cookie
      request.cookie_jar.delete(ADMIN_USER_SESSION_COOKIE_NAME)
    end

    def create_admin_user_session(admin_user, remember_me)
      admin_user.sessions.create!(
        token:      SecureRandom.base58(ADMIN_USER_SESSION_TOKEN_LENGTH),
        remote_ip:  request.remote_ip,
        user_agent: request.user_agent,
        expires_at: remember_me ? ADMIN_USER_SESSION_REMEMBER_ME_DURATION.from_now : 1.day.from_now
      )
    end

    def find_admin_user_session(token)
      return if token.blank?

      AdminUserSession.find_by(token: token)
    end
  end
end
