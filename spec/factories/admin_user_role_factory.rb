# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_user_roles
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  admin_role_id :bigint           not null
#  admin_user_id :bigint           not null
#
# Indexes
#
#  index_admin_user_roles_on_admin_role_id                    (admin_role_id)
#  index_admin_user_roles_on_admin_user_id_and_admin_role_id  (admin_user_id,admin_role_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (admin_role_id => admin_roles.id)
#  fk_rails_...  (admin_user_id => admin_users.id)
#
FactoryBot.define do
  factory :admin_user_role do
    admin_user
    admin_role
  end
end
