# frozen_string_literal: true

class AdminRolePermission < ApplicationRecord
  belongs_to :admin_role
  belongs_to :admin_permission
end
