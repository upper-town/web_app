# frozen_string_literal: true

# == Route Map
#
#                            Prefix Verb   URI Pattern                             Controller#Action
#                  new_user_session GET    /users/sign_in(.:format)                users/sessions#new
#                      user_session POST   /users/sign_in(.:format)                users/sessions#create
#              destroy_user_session DELETE /users/sign_out(.:format)               users/sessions#destroy
#                 new_user_password GET    /users/password/new(.:format)           users/passwords#new
#                edit_user_password GET    /users/password/edit(.:format)          users/passwords#edit
#                     user_password PATCH  /users/password(.:format)               users/passwords#update
#                                   PUT    /users/password(.:format)               users/passwords#update
#                                   POST   /users/password(.:format)               users/passwords#create
#          cancel_user_registration GET    /users/cancel(.:format)                 users/registrations#cancel
#             new_user_registration GET    /users/sign_up(.:format)                users/registrations#new
#            edit_user_registration GET    /users/edit(.:format)                   users/registrations#edit
#                 user_registration PATCH  /users(.:format)                        users/registrations#update
#                                   PUT    /users(.:format)                        users/registrations#update
#                                   DELETE /users(.:format)                        users/registrations#destroy
#                                   POST   /users(.:format)                        users/registrations#create
#             new_user_confirmation GET    /users/confirmation/new(.:format)       users/confirmations#new
#                 user_confirmation GET    /users/confirmation(.:format)           users/confirmations#show
#                                   POST   /users/confirmation(.:format)           users/confirmations#create
#                   new_user_unlock GET    /users/unlock/new(.:format)             users/unlocks#new
#                       user_unlock GET    /users/unlock(.:format)                 users/unlocks#show
#                                   POST   /users/unlock(.:format)                 users/unlocks#create
#            new_admin_user_session GET    /admin_users/sign_in(.:format)          admin_users/sessions#new
#                admin_user_session POST   /admin_users/sign_in(.:format)          admin_users/sessions#create
#        destroy_admin_user_session DELETE /admin_users/sign_out(.:format)         admin_users/sessions#destroy
#           new_admin_user_password GET    /admin_users/password/new(.:format)     admin_users/passwords#new
#          edit_admin_user_password GET    /admin_users/password/edit(.:format)    admin_users/passwords#edit
#               admin_user_password PATCH  /admin_users/password(.:format)         admin_users/passwords#update
#                                   PUT    /admin_users/password(.:format)         admin_users/passwords#update
#                                   POST   /admin_users/password(.:format)         admin_users/passwords#create
#    cancel_admin_user_registration GET    /admin_users/cancel(.:format)           admin_users/registrations#cancel
#       new_admin_user_registration GET    /admin_users/sign_up(.:format)          admin_users/registrations#new
#      edit_admin_user_registration GET    /admin_users/edit(.:format)             admin_users/registrations#edit
#           admin_user_registration PATCH  /admin_users(.:format)                  admin_users/registrations#update
#                                   PUT    /admin_users(.:format)                  admin_users/registrations#update
#                                   DELETE /admin_users(.:format)                  admin_users/registrations#destroy
#                                   POST   /admin_users(.:format)                  admin_users/registrations#create
#       new_admin_user_confirmation GET    /admin_users/confirmation/new(.:format) admin_users/confirmations#new
#           admin_user_confirmation GET    /admin_users/confirmation(.:format)     admin_users/confirmations#show
#                                   POST   /admin_users/confirmation(.:format)     admin_users/confirmations#create
#             new_admin_user_unlock GET    /admin_users/unlock/new(.:format)       admin_users/unlocks#new
#                 admin_user_unlock GET    /admin_users/unlock(.:format)           admin_users/unlocks#show
#                                   POST   /admin_users/unlock(.:format)           admin_users/unlocks#create
#                              root GET    /                                       home#index
#                             admin GET    /admin(.:format)                        redirect(301, /admin/dashboard)
#                   admin_dashboard GET    /admin/dashboard(.:format)              admin/dashboards#show
#                       admin_users GET    /admin/users(.:format)                  admin/users#index
#                   edit_admin_user GET    /admin/users/:id/edit(.:format)         admin/users#edit
#                        admin_user GET    /admin/users/:id(.:format)              admin/users#show
#                                   PATCH  /admin/users/:id(.:format)              admin/users#update
#                                   PUT    /admin/users/:id(.:format)              admin/users#update
#                 admin_admin_users GET    /admin/admin_users(.:format)            admin/admin_users#index
#                                   POST   /admin/admin_users(.:format)            admin/admin_users#create
#              new_admin_admin_user GET    /admin/admin_users/new(.:format)        admin/admin_users#new
#             edit_admin_admin_user GET    /admin/admin_users/:id/edit(.:format)   admin/admin_users#edit
#                  admin_admin_user GET    /admin/admin_users/:id(.:format)        admin/admin_users#show
#                                   PATCH  /admin/admin_users/:id(.:format)        admin/admin_users#update
#                                   PUT    /admin/admin_users/:id(.:format)        admin/admin_users#update
#                                   DELETE /admin/admin_users/:id(.:format)        admin/admin_users#destroy
#                       sidekiq_web        /admin/sidekiq                          Sidekiq::Web
#  turbo_recede_historical_location GET    /recede_historical_location(.:format)   turbo/native/navigation#recede
#  turbo_resume_historical_location GET    /resume_historical_location(.:format)   turbo/native/navigation#resume
# turbo_refresh_historical_location GET    /refresh_historical_location(.:format)  turbo/native/navigation#refresh

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations:      'users/confirmations',
    passwords:          'users/passwords',
    registrations:      'users/registrations',
    sessions:           'users/sessions',
    unlocks:            'users/unlocks',
  }
  devise_for :admin_users, controllers: {
    confirmations:      'admin_users/confirmations',
    passwords:          'admin_users/passwords',
    registrations:      'admin_users/registrations',
    sessions:           'admin_users/sessions',
    unlocks:            'admin_users/unlocks',
  }

  root to: 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/admin', to: redirect('/admin/dashboard')

  namespace :admin do
    resource :dashboard, only: [:show]
    resources :users, only: [:index, :show, :edit, :update]
    resources :admin_users
  end

  # Sidekiq

  authenticate(
    :admin_user,
    lambda { |admin_user| Admin::AccessPolicy.new(admin_user, 'access_sidekiq').allowed? }
  ) do
    mount Sidekiq::Web => '/admin/sidekiq', as: :sidekiq_web
  end
end
