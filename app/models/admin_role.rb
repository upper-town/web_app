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
  has_many :admin_user_roles, dependent: :destroy
  has_many :admin_role_permissions, dependent: :destroy

  has_many :admin_users, through: :admin_user_roles
  has_many :permissions, through: :admin_role_permissions, source: :admin_permission

  validates :key, :description, presence: true
end
