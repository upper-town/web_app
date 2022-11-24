# frozen_string_literal: true

class AdminPermission < ApplicationRecord
  has_many :admin_role_permissions, dependent: :destroy
  has_many :roles, through: :admin_role_permissions, source: :admin_role
  has_many :admin_users, through: :roles

  validates :key, :description, presence: true
end
