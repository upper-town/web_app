# frozen_string_literal: true

require_relative 'routes/auth_routes'
require_relative 'routes/admin_auth_routes'
require_relative 'routes/admin_routes'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  auth_routes
  admin_auth_routes

  # /admin

  admin_routes

  # /

  root to: 'home#index'

  resources :servers, only: [:index, :show] do
    resources :server_votes, as: 'votes', path: 'votes', only: [:index, :new, :create]
  end
  resources :server_votes, only: [:show]
  resources :server_banner_images, only: [:show]

  # /u/

  resources :accounts, path: 'u', only: [:show]

  # /i/

  namespace :inside, path: 'i' do
    root to: 'dashboards#show'

    resource :dashboard, only: [:show]
    resource :account, only: [:show]
    resource :user, module: :users do
      resource :change_email_confirmation, only: [:new, :create]
    end
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
