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
class AdminRole < ApplicationRecord
  has_many :admin_account_roles, dependent: :destroy
  has_many :admin_role_permissions, dependent: :destroy

  has_many :accounts, through: :admin_account_roles, source: :admin_account
  has_many :permissions, through: :admin_role_permissions, source: :admin_permission

  normalizes :key, with: ->(str) { str.downcase.squish.tr(' ', '_') }
  normalizes :description, with: ->(str) { str.squish }

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end
