# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  match "(*any)", to: redirect(subdomain: ""), via: :all, constraints: { subdomain: "www" }

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # /

  root to: "home#index"

  resources :servers, only: [:index, :show] do
    resources :server_votes, as: "votes", path: "votes", only: [:index, :new, :create]
  end
  resources :server_votes, only: [:show]

  # /users

  scope(path: "users", module: "users", as: "users") do
    get "sign_up",  to: "email_confirmations#new"
    get "sign_in",  to: "sessions#new"
    get "sign_out", to: "sessions#destroy"

    resource  :email_confirmation, only: [:create, :edit, :update]
    resource  :password_reset, only: [:new, :create, :edit, :update]
    resource  :change_email_confirmation, only: [:new, :create, :edit, :update]
    resource  :change_email_reversion, only: [:edit, :update]
    resources :sessions, only: [:create] do
      collection do
        delete "destroy_all", to: "sessions#destroy_all"
      end
    end
  end

  # /admin_users

  scope(path: "admin_users", module: "admin_users", as: "admin_users") do
    get "sign_up",  to: "email_confirmations#new"
    get "sign_in",  to: "sessions#new"
    get "sign_out", to: "sessions#destroy"

    resource  :email_confirmation, only: [:create, :edit, :update]
    resource  :password_reset, only: [:new, :create, :edit, :update]
    resources :sessions, only: [:create] do
      collection do
        delete "destroy_all", to: "sessions#destroy_all"
      end
    end
  end

  # /admin

  constraints(Admin::Constraint.new) do
    scope(path: "admin", module: "admin", as: "admin") do
      root to: "dashboards#show"

      resource  :dashboard, only: [:show]
      resources :users, only: [:index, :show, :edit]
      resources :admin_users
      resources :servers, only: [:index, :show, :new, :create, :edit, :update]

      constraints(Admin::JobsConstraint.new) do
        mount MissionControl::Jobs::Engine, at: "/jobs"
      end
    end
  end

  # /demo/

  constraints(Demo::Constraint.new) do
    scope(path: "demo", module: "demo", as: "demo") do
      root to: "home#index"

      get "uppertown_8ca7fa4c.json" => "home#uppertown_json"

      resource :webhook_events, only: [:create]
    end
  end

  # /u/

  resources :accounts, path: "u", only: [:show]

  # /i/

  scope(path: "i", module: "inside", as: "inside") do
    root to: "dashboards#show"

    resource :dashboard, only: [:show]
    resource :account, only: [:show]
    resources :servers, only: [:index, :new, :create, :edit, :update] do
      member do
        post :archive
        post :unarchive
        post :mark_for_deletion
        post :unmark_for_deletion
      end
    end
    resources :server_votes, only: [:index]
  end
end
