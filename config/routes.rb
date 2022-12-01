# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  devise_for :admin_users, controllers: {
    sessions: 'admin_users/sessions'
  }

  root to: 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :admin do
    resource :dashboard, only: [:show]
    resource :users, only: [:index, :show, :edit, :update]
    resource :admin_users
  end

  # Sidekiq

  authenticate(
    :admin_user,
    lambda { |admin_user| Admin::AccessPolicy.new(admin_user, 'access_sidekiq').allowed? }
  ) do
    mount Sidekiq::Web => '/sidekiq', as: :sidekiq_web
  end
end
