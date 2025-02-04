# frozen_string_literal: true

FactoryBot.define do
  factory :admin_account_role do
    admin_account
    admin_role
  end
end
