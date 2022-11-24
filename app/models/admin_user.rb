# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are: :omniauthable
  devise(
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :lockable,
    :timeoutable,
    :trackable
  )

  has_many :admin_user_roles, dependent: :destroy
  has_many :roles, through: :admin_user_roles, source: :admin_role
  has_many :permissions, through: :roles

  # Super Admin status can only be granted through env var.
  def super_admin?
    ENV.fetch('SUPER_ADMIN_USER_EMAILS').delete(' ').split(',').include?(email)
  end
end
