# frozen_string_literal: true

module Auth
  module ManageActiveSession
    REMEMBER_ME_DURATION = 4.months

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable ThreadSafety/InstanceVariableInClassMethod
    def self.[](auth_model)
      Module.new do
        extend ActiveSupport::Concern

        included do
          cattr_reader(:auth_model, default: auth_model)
          cattr_reader(
            :auth_active_session_model,
            default: auth_model.reflect_on_association(:active_sessions).options[:class_name].constantize
          )
        end

        def current_model_active_session
          Current.auth_model_active_session ||= find_active_session(read_cookie)
        end

        def current_model
          Current.auth_model ||= current_model_active_session&.model
        end

        def current_model_account
          Current.auth_model_account ||= current_model&.account
        end

        def signed_in?
          current_model.present?
        end

        def signed_out?
          !signed_in?
        end

        def sign_in!(record, remember_me = false)
          active_session = create_active_session(record, remember_me)
          store_cookie(active_session.uuid, remember_me)
        end

        def sign_out!
          current_model_active_session&.destroy!
          delete_cookie
        end

        private

        def cookie_name
          @cookie_name ||= auth_active_session_model.name.underscore
        end

        def store_cookie(active_session_uuid, remember_me)
          request.cookie_jar.encrypted[cookie_name] = {
            value: active_session_uuid,
            expires: remember_me ? REMEMBER_ME_DURATION : nil,
            httponly: true,
            secure: Rails.env.production?
          }
        end

        def read_cookie
          request.cookie_jar.encrypted[cookie_name]
        end

        def delete_cookie
          request.cookie_jar.delete(cookie_name)
        end

        def create_active_session(record, remember_me)
          record.active_sessions.create!(
            uuid:       SecureRandom.uuid,
            remote_ip:  request.remote_ip,
            user_agent: request.user_agent,
            expires_at: remember_me ? REMEMBER_ME_DURATION.from_now : 1.day.from_now
          )
        end

        def find_active_session(uuid)
          return if uuid.blank?

          auth_active_session_model.find_by(uuid: uuid)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable ThreadSafety/InstanceVariableInClassMethod
  end
end
