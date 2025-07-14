# frozen_string_literal: true

module Auth
  module ManageSession
    SESSION_NAME = "session"
    SESSION_MIN_DURATION = 1.day
    SESSION_MAX_DURATION = 4.months

    extend ActiveSupport::Concern

    include JsonCookie

    def current_session
      Current.session ||= find_session
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
      attributes = create_session(user, remember_me)
      write_session_value(attributes, remember_me)
    end

    def sign_out_user!(destroy_all: false)
      if current_session
        current_session.destroy!
        Session.where(user: current_session.user).destroy_all if destroy_all
      end

      delete_session_value
    end

    private

    def read_session_value
      SessionValue.new(read_json_cookie(SESSION_NAME))
    end

    def write_session_value(attributes, remember_me)
      write_json_cookie(
        SESSION_NAME,
        SessionValue.new(attributes),
        expires: remember_me ? SESSION_MAX_DURATION : nil
      )
    end

    def delete_session_value
      delete_json_cookie(SESSION_NAME)
    end

    def create_session(user, remember_me)
      token, token_digest, token_last_four = TokenGenerator::Session.generate

      user.sessions.create!(
        token_digest:,
        token_last_four:,
        remote_ip:  request.remote_ip,
        user_agent: request.user_agent,
        expires_at: remember_me ? SESSION_MAX_DURATION.from_now : SESSION_MIN_DURATION.from_now
      )

      { token: }
    end

    def find_session
      session_value = read_session_value
      return if session_value.invalid?

      Session.find_by_token(session_value.token)
    end

    class SessionValue < ApplicationModel
      attribute :token, :string, default: ""

      validates :token, presence: true
    end
  end
end
