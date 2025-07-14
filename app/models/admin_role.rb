# frozen_string_literal: true

class AdminRole < ApplicationRecord
  has_many :admin_account_roles, dependent: :destroy
  has_many :admin_role_permissions, dependent: :destroy

  has_many :accounts, through: :admin_account_roles, source: :admin_account
  has_many :permissions, through: :admin_role_permissions, source: :admin_permission

  normalizes :key,         with: NormalizeNameKey
  normalizes :description, with: NormalizeDescription

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end
