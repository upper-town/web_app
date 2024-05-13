# frozen_string_literal: true

module Auth
  module UserManageSession
    USER_SESSION_COOKIE_NAME = 'user_session'
    USER_SESSION_REMEMBER_ME_DURATION = 4.months
    USER_SESSION_TOKEN_LENGTH = 44

    extend ActiveSupport::Concern

    def current_user_session
      Current.user_session ||= find_user_session(read_user_session_cookie)
    end

    def current_user
      Current.user ||= current_user_session&.user
    end

    def current_user_account
      Current.user_account ||= current_user&.account
    end

    def signed_in_user?
      current_user.present?
    end

    def signed_out_user?
      !signed_in_user?
    end

    def sign_in_user!(user, remember_me = false)
      user_session = create_user_session(user, remember_me)
      store_user_session_cookie(user_session.token, remember_me)
    end

    def sign_out_user!
      current_user_session&.destroy!
      delete_user_session_cookie
    end

    private

    def store_user_session_cookie(token, remember_me)
      request.cookie_jar[USER_SESSION_COOKIE_NAME] = {
        value: token,
        expires: remember_me ? USER_SESSION_REMEMBER_ME_DURATION : nil,
        httponly: true,
        secure: Rails.env.production?
      }
    end

    def read_user_session_cookie
      request.cookie_jar[USER_SESSION_COOKIE_NAME]
    end

    def delete_user_session_cookie
      request.cookie_jar.delete(USER_SESSION_COOKIE_NAME)
    end

    def create_user_session(user, remember_me)
      user.sessions.create!(
        token:      SecureRandom.base58(USER_SESSION_TOKEN_LENGTH),
        remote_ip:  request.remote_ip,
        user_agent: request.user_agent,
        expires_at: remember_me ? USER_SESSION_REMEMBER_ME_DURATION.from_now : 1.day.from_now
      )
    end

    def find_user_session(token)
      return if token.blank?

      UserSession.find_by(token: token)
    end
  end
end
