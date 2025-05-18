# frozen_string_literal: true

module ActionDispatch
  module Routing
    class Mapper
      def admin_auth_routes
        name = "admin_users"
        salt = ENV.fetch("ADMIN_AUTH_ROUTES_SALT", "")
        salted_name = salt.present? ? "#{name}_#{salt}" : name

        scope(salted_name, module: name, as: name, path: name) do
          get "sign_up",  to: "email_confirmations#new"
          get "sign_in",  to: "sessions#new"
          get "sign_out", to: "sessions#destroy"

          resource  :email_confirmation, only: [:create, :edit, :update]
          resource  :change_email_confirmation, only: [:edit, :update]
          resource  :change_email_reversion, only: [:edit, :update]
          resource  :password_reset, only: [:new, :create, :edit, :update]
          resources :sessions, only: [:create] do
            member do
              delete "destroy_all", to: "sessions#destroy_all"
            end
          end
        end
      end
    end
  end
end
