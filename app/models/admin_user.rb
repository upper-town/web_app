# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_admin_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_admin_users_on_email                 (email) UNIQUE
#  index_admin_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_admin_users_on_unlock_token          (unlock_token) UNIQUE
#
class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are: :omniauthable
  devise(
    :database_authenticatable,
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
