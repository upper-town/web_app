# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user_session
  attribute :user
  attribute :user_account

  attribute :admin_user_session
  attribute :admin_user
  attribute :admin_user_account
end
