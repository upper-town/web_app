# frozen_string_literal: true

class AdminPermission < ApplicationRecord
  has_many :admin_role_permissions
  has_many :roles, class_name: 'AdminRole', through: :admin_role_permissions
  has_many :admin_users, through: :roles

  validates :key, :description, presence: true
end
