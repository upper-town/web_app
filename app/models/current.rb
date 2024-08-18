# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user
  attribute :account

  attribute :admin_session
  attribute :admin_user
  attribute :admin_account
end
