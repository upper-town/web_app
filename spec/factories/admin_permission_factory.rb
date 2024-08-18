# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_permissions
#
#  id          :bigint           not null, primary key
#  description :string           default(""), not null
#  key         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_admin_permissions_on_key  (key) UNIQUE
#
FactoryBot.define do
  factory :admin_permission do
    sequence(:key) { |n| "admin_permission_key_#{n}" }
    description { 'AdminPermission' }
  end
end
