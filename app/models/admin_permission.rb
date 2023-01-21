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

  has_many :roles,       through: :admin_role_permissions, source: :admin_role
  has_many :admin_users, through: :roles

  validates :key, :description, presence: true
end
