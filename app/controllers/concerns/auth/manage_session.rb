# frozen_string_literal: true

module Auth
  module ManageSession
    SESSION_COOKIE_NAME = 'session'
    SESSION_REMEMBER_ME_DURATION = 4.months
    SESSION_TOKEN_LENGTH = 44

    extend ActiveSupport::Concern

    def current_session
      Current.session ||= find_session(read_session_cookie)
    end

    def current_user
      Current.user ||= current_session&.user
    end

    def current_account
      Current.account ||= current_user&.account
    end

    def signed_in_user?
      current_user.present?
    end

    def signed_out_user?
      !signed_in_user?
    end

    def sign_in_user!(user, remember_me = false)
      session = create_session(user, remember_me)
      store_session_cookie(session.token, remember_me)
    end

    def sign_out_user!
      current_session&.destroy!
      delete_session_cookie
    end

    private

    def store_session_cookie(token, remember_me)
      request.cookie_jar[SESSION_COOKIE_NAME] = {
        value: token,
        expires: remember_me ? SESSION_REMEMBER_ME_DURATION : nil,
        httponly: true,
        secure: Rails.env.production?
      }
    end

    def read_session_cookie
      request.cookie_jar[SESSION_COOKIE_NAME]
    end

    def delete_session_cookie
      request.cookie_jar.delete(SESSION_COOKIE_NAME)
    end

    def create_session(user, remember_me)
      user.sessions.create!(
        token:      SecureRandom.base58(SESSION_TOKEN_LENGTH),
        remote_ip:  request.remote_ip,
        user_agent: request.user_agent,
        expires_at: remember_me ? SESSION_REMEMBER_ME_DURATION.from_now : 1.day.from_now
      )
    end

    def find_session(token)
      return if token.blank?

      Session.find_by(token: token)
    end
  end
end
