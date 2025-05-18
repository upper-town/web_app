class AdminAccountRole < ApplicationRecord
  belongs_to :admin_account
  belongs_to :admin_role

  validates :admin_role_id, uniqueness: { scope: :admin_account_id }
end
