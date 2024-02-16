# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_user_account_roles
#
#  id                    :bigint           not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  admin_role_id         :bigint           not null
#  admin_user_account_id :bigint           not null
#
# Indexes
#
#  index_admin_user_account_roles_account_id_role_id  (admin_user_account_id,admin_role_id) UNIQUE
#  index_admin_user_account_roles_on_admin_role_id    (admin_role_id)
#
# Foreign Keys
#
#  fk_rails_...  (admin_role_id => admin_roles.id)
#  fk_rails_...  (admin_user_account_id => admin_user_accounts.id)
#
class AdminUserAccountRole < ApplicationRecord
  belongs_to :admin_user_account
  belongs_to :admin_role
end
