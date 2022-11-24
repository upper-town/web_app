# frozen_string_literal: true

class AdminRole < ApplicationRecord
  has_many :admin_user_roles, dependent: :destroy
  has_many :admin_role_permissions
  has_many :admin_users, through: :admin_user_roles
  has_many :permissions, through: :admin_role_permissions, source: :admin_permission

  validates :key, :description, presence: true
end
