# frozen_string_literal: true

module Auth
  module AdminManageSession
    ADMIN_SESSION_COOKIE_NAME = 'admin_session'
    ADMIN_SESSION_REMEMBER_ME_DURATION = 4.months
    ADMIN_SESSION_TOKEN_LENGTH = 44

    extend ActiveSupport::Concern

    def current_admin_session
      Current.admin_session ||= find_admin_session(read_admin_session_cookie)
    end

    def current_admin_user
      Current.admin_user ||= current_admin_session&.admin_user
    end

    def current_admin_account
      Current.admin_account ||= current_admin_user&.account
    end

    def signed_in_admin_user?
      current_admin_user.present?
    end

    def signed_out_admin_user?
      !signed_in_admin_user?
    end

    def sign_in_admin_user!(admin_user, remember_me = false)
      admin_session = create_admin_session(admin_user, remember_me)
      store_admin_session_cookie(admin_session, remember_me)
    end

    def sign_out_admin_user!
      current_admin_session&.destroy!
      delete_admin_session_cookie
    end

    private

    def store_admin_session_cookie(admin_session, remember_me)
      cookie_value = "#{admin_session.admin_user_id}:#{admin_session.token}"

      request.cookie_jar[ADMIN_SESSION_COOKIE_NAME] = {
        value: cookie_value,
        expires: remember_me ? ADMIN_SESSION_REMEMBER_ME_DURATION : nil,
        httponly: true,
        secure: Rails.env.production?
      }
    end

    def read_admin_session_cookie
      request.cookie_jar[ADMIN_SESSION_COOKIE_NAME]
    end

    def delete_admin_session_cookie
      request.cookie_jar.delete(ADMIN_SESSION_COOKIE_NAME)
    end

    def create_admin_session(admin_user, remember_me)
      admin_user.sessions.create!(
        token:      SecureRandom.base58(ADMIN_SESSION_TOKEN_LENGTH),
        remote_ip:  request.remote_ip,
        user_agent: request.user_agent,
        expires_at: remember_me ? ADMIN_SESSION_REMEMBER_ME_DURATION.from_now : 1.day.from_now
      )
    end

    def find_admin_session(cookie_value)
      return if cookie_value.blank?

      admin_user_id, token = cookie_value.split(':')
      return if admin_user_id.blank? || token.blank?

      AdminSession.find_by(admin_user_id: admin_user_id, token: token)
    end
  end
end
