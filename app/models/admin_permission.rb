# frozen_string_literal: true

class AdminPermission < ApplicationRecord
  JOBS_ACCESS = 'jobs_access'

  has_many :admin_role_permissions, dependent: :destroy

  has_many :roles, through: :admin_role_permissions, source: :admin_role
  has_many :accounts, -> { distinct }, through: :roles

  normalizes :key, with: ->(str) { str.downcase.squish.tr(' ', '_') }
  normalizes :description, with: ->(str) { str.squish }

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end
