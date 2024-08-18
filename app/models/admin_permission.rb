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
class AdminPermission < ApplicationRecord
  has_many :admin_role_permissions, dependent: :destroy

  has_many :roles, through: :admin_role_permissions, source: :admin_role
  has_many :accounts, -> { distinct }, through: :roles

  normalizes :key, with: ->(str) { str.downcase.squish.tr(' ', '_') }
  normalizes :description, with: ->(str) { str.squish }

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end
