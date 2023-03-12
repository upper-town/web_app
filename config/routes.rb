# frozen_string_literal: true

# == Route Map
#
#                            Prefix Verb   URI Pattern                                Controller#Action
#                              root GET    /                                          home#index
#                      server_votes GET    /servers/:server_suuid/votes(.:format)     server_votes#index
#                                   POST   /servers/:server_suuid/votes(.:format)     server_votes#create
#                   new_server_vote GET    /servers/:server_suuid/votes/new(.:format) server_votes#new
#                           servers GET    /servers(.:format)                         servers#index
#                            server GET    /servers/:suuid(.:format)                  servers#show
#                       server_vote GET    /server_votes/:suuid(.:format)             server_votes#show
#                  new_user_session GET    /users/sign_in(.:format)                   users/sessions#new
#                      user_session POST   /users/sign_in(.:format)                   users/sessions#create
#              destroy_user_session DELETE /users/sign_out(.:format)                  users/sessions#destroy
#                 new_user_password GET    /users/password/new(.:format)              users/passwords#new
#                edit_user_password GET    /users/password/edit(.:format)             users/passwords#edit
#                     user_password PATCH  /users/password(.:format)                  users/passwords#update
#                                   PUT    /users/password(.:format)                  users/passwords#update
#                                   POST   /users/password(.:format)                  users/passwords#create
#          cancel_user_registration GET    /users/cancel(.:format)                    users/registrations#cancel
#             new_user_registration GET    /users/sign_up(.:format)                   users/registrations#new
#            edit_user_registration GET    /users/edit(.:format)                      users/registrations#edit
#                 user_registration PATCH  /users(.:format)                           users/registrations#update
#                                   PUT    /users(.:format)                           users/registrations#update
#                                   DELETE /users(.:format)                           users/registrations#destroy
#                                   POST   /users(.:format)                           users/registrations#create
#             new_user_confirmation GET    /users/confirmation/new(.:format)          users/confirmations#new
#                 user_confirmation GET    /users/confirmation(.:format)              users/confirmations#show
#                                   POST   /users/confirmation(.:format)              users/confirmations#create
#                   new_user_unlock GET    /users/unlock/new(.:format)                users/unlocks#new
#                       user_unlock GET    /users/unlock(.:format)                    users/unlocks#show
#                                   POST   /users/unlock(.:format)                    users/unlocks#create
#            new_admin_user_session GET    /admin_users/sign_in(.:format)             admin_users/sessions#new
#                admin_user_session POST   /admin_users/sign_in(.:format)             admin_users/sessions#create
#        destroy_admin_user_session DELETE /admin_users/sign_out(.:format)            admin_users/sessions#destroy
#           new_admin_user_password GET    /admin_users/password/new(.:format)        admin_users/passwords#new
#          edit_admin_user_password GET    /admin_users/password/edit(.:format)       admin_users/passwords#edit
#               admin_user_password PATCH  /admin_users/password(.:format)            admin_users/passwords#update
#                                   PUT    /admin_users/password(.:format)            admin_users/passwords#update
#                                   POST   /admin_users/password(.:format)            admin_users/passwords#create
#       new_admin_user_confirmation GET    /admin_users/confirmation/new(.:format)    admin_users/confirmations#new
#           admin_user_confirmation GET    /admin_users/confirmation(.:format)        admin_users/confirmations#show
#                                   POST   /admin_users/confirmation(.:format)        admin_users/confirmations#create
#             new_admin_user_unlock GET    /admin_users/unlock/new(.:format)          admin_users/unlocks#new
#                 admin_user_unlock GET    /admin_users/unlock(.:format)              admin_users/unlocks#show
#                                   POST   /admin_users/unlock(.:format)              admin_users/unlocks#create
#                      user_account GET    /u/:suuid(.:format)                        user_accounts#show
#                  inside_dashboard GET    /i/dashboard(.:format)                     inside/dashboards#show
#               inside_user_account GET    /i/user_account(.:format)                  inside/user_accounts#show
#                    inside_servers GET    /i/servers(.:format)                       inside/servers#index
#                                   POST   /i/servers(.:format)                       inside/servers#create
#                 new_inside_server GET    /i/servers/new(.:format)                   inside/servers#new
#               inside_server_votes GET    /i/server_votes(.:format)                  inside/server_votes#index
#                             admin GET    /admin(.:format)                           redirect(301, /admin/dashboard)
#                        admin_demo GET    /admin/demo(.:format)                      admin/demos#show
#                   admin_dashboard GET    /admin/dashboard(.:format)                 admin/dashboards#show
#                       admin_users GET    /admin/users(.:format)                     admin/users#index
#                        admin_user GET    /admin/users/:id(.:format)                 admin/users#show
#                 admin_admin_users GET    /admin/admin_users(.:format)               admin/admin_users#index
#                                   POST   /admin/admin_users(.:format)               admin/admin_users#create
#              new_admin_admin_user GET    /admin/admin_users/new(.:format)           admin/admin_users#new
#             edit_admin_admin_user GET    /admin/admin_users/:id/edit(.:format)      admin/admin_users#edit
#                  admin_admin_user GET    /admin/admin_users/:id(.:format)           admin/admin_users#show
#                                   PATCH  /admin/admin_users/:id(.:format)           admin/admin_users#update
#                                   PUT    /admin/admin_users/:id(.:format)           admin/admin_users#update
#                                   DELETE /admin/admin_users/:id(.:format)           admin/admin_users#destroy
#                     admin_servers GET    /admin/servers(.:format)                   admin/servers#index
#                                   POST   /admin/servers(.:format)                   admin/servers#create
#                  new_admin_server GET    /admin/servers/new(.:format)               admin/servers#new
#                 edit_admin_server GET    /admin/servers/:id/edit(.:format)          admin/servers#edit
#                      admin_server GET    /admin/servers/:id(.:format)               admin/servers#show
#                                   PATCH  /admin/servers/:id(.:format)               admin/servers#update
#                                   PUT    /admin/servers/:id(.:format)               admin/servers#update
#                                   DELETE /admin/servers/:id(.:format)               admin/servers#destroy
#                       sidekiq_web        /admin/sidekiq                             Sidekiq::Web
#  turbo_recede_historical_location GET    /recede_historical_location(.:format)      turbo/native/navigation#recede
#  turbo_resume_historical_location GET    /resume_historical_location(.:format)      turbo/native/navigation#resume
# turbo_refresh_historical_location GET    /refresh_historical_location(.:format)     turbo/native/navigation#refresh

require 'sidekiq/web'
require 'sidekiq/cron/web'
require 'sidekiq_unique_jobs/web'

Rails.application.routes.draw do
  # /

  root to: 'home#index'

  resources :servers, only: [:index, :show], param: :suuid do
    resources :server_votes, as: 'votes', path: 'votes', only: [:index, :new, :create]
  end
  resources :server_votes, only: [:show], param: :suuid

  # /users/

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords:     'users/passwords',
    registrations: 'users/registrations',
    sessions:      'users/sessions',
    unlocks:       'users/unlocks',
  }

  # /admin_users/

  devise_for :admin_users, controllers: {
    confirmations: 'admin_users/confirmations',
    passwords:     'admin_users/passwords',
    sessions:      'admin_users/sessions',
    unlocks:       'admin_users/unlocks',
  }

  # /u/

  resources :user_accounts, path: 'u', only: [:show], param: :suuid

  # /i/

  namespace :inside, path: 'i' do
    resource :dashboard, only: [:show]
    resource :user_account, only: [:show]
    resources :servers, only: [:index, :new, :create]
    resources :server_votes, only: [:index]
  end

  # /admin/

  get '/admin', to: redirect('/admin/dashboard')

  namespace :admin do
    resource :demo, only: [:show]
    resource :dashboard, only: [:show]
    resources :users, only: [:index, :show]
    resources :admin_users
    resources :servers, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  end

  authenticate(
    :admin_user,
    lambda { |admin_user| Admin::AccessPolicy.new(admin_user, 'access_sidekiq').allowed? }
  ) do
    mount Sidekiq::Web => '/admin/sidekiq', as: :sidekiq_web
  end
end
