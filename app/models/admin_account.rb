class AdminAccount < ApplicationRecord
  belongs_to :admin_user

  has_many :admin_account_roles, dependent: :destroy

  has_many :roles, through: :admin_account_roles, source: :admin_role
  has_many :permissions, -> { distinct }, through: :roles

  # Super Admin status can only be granted through env var.
  def super_admin?
    StringValueHelper.values_list_uniq(ENV.fetch("SUPER_ADMIN_ACCOUNT_IDS", "")).include?(id.to_s)
  end
end
