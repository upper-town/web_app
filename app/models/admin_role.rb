# frozen_string_literal: true

class AdminRole < ApplicationRecord
  has_many :admin_user_roles
  has_many :admin_role_permissions
  has_many :admin_users, through: :admin_user_roles
  has_many :permissions, class_name: 'AdminPermission', through: :admin_role_permissions

  validates :key, :description, presence: true
end
