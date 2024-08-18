# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_roles
#
#  id          :bigint           not null, primary key
#  description :string           default(""), not null
#  key         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_admin_roles_on_key  (key) UNIQUE
#
FactoryBot.define do
  factory :admin_role do
    sequence(:key) { |n| "admin_role_key_#{n}" }
    description { 'AdminRole' }
  end
end
