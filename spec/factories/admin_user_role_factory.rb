# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user_role do
    admin_user
    admin_role
  end
end
