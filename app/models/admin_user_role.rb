# frozen_string_literal: true

class AdminUserRole < ApplicationRecord
  belongs_to :admin_user
  belongs_to :admin_role
end
