# frozen_string_literal: true

FactoryBot.define do
  factory :admin_role_permission do
    admin_role
    admin_permission
  end
end
