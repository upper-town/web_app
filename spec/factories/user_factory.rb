# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user.#{n}@upper.town" }
  end
end
