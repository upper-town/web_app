# frozen_string_literal: true

module ActionDispatch
  module Routing
    class Mapper
      def admin_routes
        name = 'admin'

        constraints(Admin::Constraint.new) do
          scope(name, module: name, as: name, path: name) do
            root to: 'dashboards#show'

            resource  :dashboard, only: [:show]
            resource  :demo, only: [:show]
            resources :users, only: [:index, :show, :edit]
            resources :admin_users
            resources :servers, only: [:index, :show, :new, :create, :edit, :update]

            constraints(Admin::SidekiqConstraint.new) do
              mount Sidekiq::Web => '/sidekiq', as: :sidekiq_web
            end
          end
        end
      end
    end
  end
end
