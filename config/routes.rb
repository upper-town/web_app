# frozen_string_literal: true

# == Route Map
#
#                                     Prefix Verb   URI Pattern                                            Controller#Action
#                              users_sign_up GET    /users/sign_up(.:format)                               users/email_confirmations#new
#                              users_sign_in GET    /users/sign_in(.:format)                               users/sessions#new
#                             users_sign_out GET    /users/sign_out(.:format)                              users/sessions#destroy
#              edit_users_email_confirmation GET    /users/email_confirmation/edit(.:format)               users/email_confirmations#edit
#                   users_email_confirmation PATCH  /users/email_confirmation(.:format)                    users/email_confirmations#update
#                                            PUT    /users/email_confirmation(.:format)                    users/email_confirmations#update
#                                            POST   /users/email_confirmation(.:format)                    users/email_confirmations#create
#       edit_users_change_email_confirmation GET    /users/change_email_confirmation/edit(.:format)        users/change_email_confirmations#edit
#            users_change_email_confirmation PATCH  /users/change_email_confirmation(.:format)             users/change_email_confirmations#update
#                                            PUT    /users/change_email_confirmation(.:format)             users/change_email_confirmations#update
#          edit_users_change_email_reversion GET    /users/change_email_reversion/edit(.:format)           users/change_email_reversions#edit
#               users_change_email_reversion PATCH  /users/change_email_reversion(.:format)                users/change_email_reversions#update
#                                            PUT    /users/change_email_reversion(.:format)                users/change_email_reversions#update
#                   new_users_password_reset GET    /users/password_reset/new(.:format)                    users/password_resets#new
#                  edit_users_password_reset GET    /users/password_reset/edit(.:format)                   users/password_resets#edit
#                       users_password_reset PATCH  /users/password_reset(.:format)                        users/password_resets#update
#                                            PUT    /users/password_reset(.:format)                        users/password_resets#update
#                                            POST   /users/password_reset(.:format)                        users/password_resets#create
#                  destroy_all_users_session DELETE /users/sessions/:id/destroy_all(.:format)              users/sessions#destroy_all
#                             users_sessions POST   /users/sessions(.:format)                              users/sessions#create
#                        admin_users_sign_up GET    /admin_users_/sign_up(.:format)                        admin_users/email_confirmations#new
#                        admin_users_sign_in GET    /admin_users_/sign_in(.:format)                        admin_users/sessions#new
#                       admin_users_sign_out GET    /admin_users_/sign_out(.:format)                       admin_users/sessions#destroy
#        edit_admin_users_email_confirmation GET    /admin_users_/email_confirmation/edit(.:format)        admin_users/email_confirmations#edit
#             admin_users_email_confirmation PATCH  /admin_users_/email_confirmation(.:format)             admin_users/email_confirmations#update
#                                            PUT    /admin_users_/email_confirmation(.:format)             admin_users/email_confirmations#update
#                                            POST   /admin_users_/email_confirmation(.:format)             admin_users/email_confirmations#create
# edit_admin_users_change_email_confirmation GET    /admin_users_/change_email_confirmation/edit(.:format) admin_users/change_email_confirmations#edit
#      admin_users_change_email_confirmation PATCH  /admin_users_/change_email_confirmation(.:format)      admin_users/change_email_confirmations#update
#                                            PUT    /admin_users_/change_email_confirmation(.:format)      admin_users/change_email_confirmations#update
#    edit_admin_users_change_email_reversion GET    /admin_users_/change_email_reversion/edit(.:format)    admin_users/change_email_reversions#edit
#         admin_users_change_email_reversion PATCH  /admin_users_/change_email_reversion(.:format)         admin_users/change_email_reversions#update
#                                            PUT    /admin_users_/change_email_reversion(.:format)         admin_users/change_email_reversions#update
#             new_admin_users_password_reset GET    /admin_users_/password_reset/new(.:format)             admin_users/password_resets#new
#            edit_admin_users_password_reset GET    /admin_users_/password_reset/edit(.:format)            admin_users/password_resets#edit
#                 admin_users_password_reset PATCH  /admin_users_/password_reset(.:format)                 admin_users/password_resets#update
#                                            PUT    /admin_users_/password_reset(.:format)                 admin_users/password_resets#update
#                                            POST   /admin_users_/password_reset(.:format)                 admin_users/password_resets#create
#            destroy_all_admin_users_session DELETE /admin_users_/sessions/:id/destroy_all(.:format)       admin_users/sessions#destroy_all
#                       admin_users_sessions POST   /admin_users_/sessions(.:format)                       admin_users/sessions#create
#                                 admin_root GET    /admin(.:format)                                       admin/dashboards#show
#                            admin_dashboard GET    /admin/dashboard(.:format)                             admin/dashboards#show
#                                 admin_demo GET    /admin/demo(.:format)                                  admin/demos#show
#                                admin_users GET    /admin/users(.:format)                                 admin/users#index
#                            edit_admin_user GET    /admin/users/:id/edit(.:format)                        admin/users#edit
#                                 admin_user GET    /admin/users/:id(.:format)                             admin/users#show
#                          admin_admin_users GET    /admin/admin_users(.:format)                           admin/admin_users#index
#                                            POST   /admin/admin_users(.:format)                           admin/admin_users#create
#                       new_admin_admin_user GET    /admin/admin_users/new(.:format)                       admin/admin_users#new
#                      edit_admin_admin_user GET    /admin/admin_users/:id/edit(.:format)                  admin/admin_users#edit
#                           admin_admin_user GET    /admin/admin_users/:id(.:format)                       admin/admin_users#show
#                                            PATCH  /admin/admin_users/:id(.:format)                       admin/admin_users#update
#                                            PUT    /admin/admin_users/:id(.:format)                       admin/admin_users#update
#                                            DELETE /admin/admin_users/:id(.:format)                       admin/admin_users#destroy
#                              admin_servers GET    /admin/servers(.:format)                               admin/servers#index
#                                            POST   /admin/servers(.:format)                               admin/servers#create
#                           new_admin_server GET    /admin/servers/new(.:format)                           admin/servers#new
#                          edit_admin_server GET    /admin/servers/:id/edit(.:format)                      admin/servers#edit
#                               admin_server GET    /admin/servers/:id(.:format)                           admin/servers#show
#                                            PATCH  /admin/servers/:id(.:format)                           admin/servers#update
#                                            PUT    /admin/servers/:id(.:format)                           admin/servers#update
#                          admin_sidekiq_web        /admin/sidekiq                                         Sidekiq::Web
#                                       root GET    /                                                      home#index
#                               server_votes GET    /servers/:server_id/votes(.:format)                    server_votes#index
#                                            POST   /servers/:server_id/votes(.:format)                    server_votes#create
#                            new_server_vote GET    /servers/:server_id/votes/new(.:format)                server_votes#new
#                                    servers GET    /servers(.:format)                                     servers#index
#                                     server GET    /servers/:id(.:format)                                 servers#show
#                                server_vote GET    /server_votes/:id(.:format)                            server_votes#show
#                        server_banner_image GET    /server_banner_images/:id(.:format)                    server_banner_images#show
#                               user_account GET    /u/:id(.:format)                                       user_accounts#show
#                                inside_root GET    /i(.:format)                                           inside/dashboards#show
#                           inside_dashboard GET    /i/dashboard(.:format)                                 inside/dashboards#show
#                        inside_user_account GET    /i/user_account(.:format)                              inside/user_accounts#show
#  new_inside_user_change_email_confirmation GET    /i/user/change_email_confirmation/new(.:format)        inside/users/change_email_confirmations#new
#      inside_user_change_email_confirmation POST   /i/user/change_email_confirmation(.:format)            inside/users/change_email_confirmations#create
#                            new_inside_user GET    /i/user/new(.:format)                                  inside/users/users#new
#                           edit_inside_user GET    /i/user/edit(.:format)                                 inside/users/users#edit
#                                inside_user GET    /i/user(.:format)                                      inside/users/users#show
#                                            PATCH  /i/user(.:format)                                      inside/users/users#update
#                                            PUT    /i/user(.:format)                                      inside/users/users#update
#                                            DELETE /i/user(.:format)                                      inside/users/users#destroy
#                                            POST   /i/user(.:format)                                      inside/users/users#create
#                      archive_inside_server POST   /i/servers/:id/archive(.:format)                       inside/servers#archive
#                    unarchive_inside_server POST   /i/servers/:id/unarchive(.:format)                     inside/servers#unarchive
#            mark_for_deletion_inside_server POST   /i/servers/:id/mark_for_deletion(.:format)             inside/servers#mark_for_deletion
#          unmark_for_deletion_inside_server POST   /i/servers/:id/unmark_for_deletion(.:format)           inside/servers#unmark_for_deletion
#                             inside_servers GET    /i/servers(.:format)                                   inside/servers#index
#                                            POST   /i/servers(.:format)                                   inside/servers#create
#                          new_inside_server GET    /i/servers/new(.:format)                               inside/servers#new
#                         edit_inside_server GET    /i/servers/:id/edit(.:format)                          inside/servers#edit
#                              inside_server PATCH  /i/servers/:id(.:format)                               inside/servers#update
#                                            PUT    /i/servers/:id(.:format)                               inside/servers#update
#                        inside_server_votes GET    /i/server_votes(.:format)                              inside/server_votes#index
#           turbo_recede_historical_location GET    /recede_historical_location(.:format)                  turbo/native/navigation#recede
#           turbo_resume_historical_location GET    /resume_historical_location(.:format)                  turbo/native/navigation#resume
#          turbo_refresh_historical_location GET    /refresh_historical_location(.:format)                 turbo/native/navigation#refresh

require 'sidekiq/web'
require 'sidekiq/cron/web'
require 'sidekiq_unique_jobs/web'

require_relative 'routes/admin_routes'
require_relative 'routes/authentication_routes'

Rails.application.routes.draw do
  auth_routes_for(:users)
  auth_routes_for(:admin_users, ENV.fetch('ADMIN_USERS_PATH_SALT'))

  admin_routes

  # /

  root to: 'home#index'

  resources :servers, only: [:index, :show] do
    resources :server_votes, as: 'votes', path: 'votes', only: [:index, :new, :create]
  end
  resources :server_votes, only: [:show]
  resources :server_banner_images, only: [:show]

  # /u/

  resources :user_accounts, path: 'u', only: [:show]

  # /i/

  namespace :inside, path: 'i' do
    root to: 'dashboards#show'

    resource :dashboard, only: [:show]
    resource :user_account, only: [:show]
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
