# frozen_string_literal: true

module Auth
  module ManageAdminSession
    ADMIN_SESSION_NAME = "admin_session"
    ADMIN_SESSION_REMEMBER_ME_DURATION = 4.months

    extend ActiveSupport::Concern

    include JsonCookie

    def current_admin_session
      Current.admin_session ||= find_admin_session
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
      token = create_admin_session(admin_user, remember_me)
      write_admin_session_value(token, remember_me)
    end

    def sign_out_admin_user!(destroy_all: false)
      if current_admin_session
        current_admin_session.destroy!
        AdminSession.where(admin_user: current_admin_session.admin_user).destroy_all if destroy_all
      end

      delete_admin_session_value
    end

    private

    def read_admin_session_value
      AdminSessionValue.new(read_json_cookie(ADMIN_SESSION_NAME))
    end

    def write_admin_session_value(token, remember_me)
      write_json_cookie(
        ADMIN_SESSION_NAME,
        AdminSessionValue.new(token: token),
        expires: remember_me ? ADMIN_SESSION_REMEMBER_ME_DURATION : nil
      )
    end

    def delete_admin_session_value
      delete_json_cookie(ADMIN_SESSION_NAME)
    end

    def create_admin_session(admin_user, remember_me)
      token, token_digest, token_last_four = TokenGenerator::AdminSession.generate

      admin_user.sessions.create!(
        token_digest: token_digest,
        token_last_four: token_last_four,
        remote_ip:  request.remote_ip,
        user_agent: request.user_agent,
        expires_at: remember_me ? ADMIN_SESSION_REMEMBER_ME_DURATION.from_now : 1.day.from_now
      )

      token
    end

    def find_admin_session
      admin_session_value = read_admin_session_value
      return if admin_session_value.invalid?

      AdminSession.find_by_token(admin_session_value.token)
    end

    class AdminSessionValue < ApplicationModel
      attribute :token, :string, default: ""

      validates :token, presence: true
    end
  end
end
