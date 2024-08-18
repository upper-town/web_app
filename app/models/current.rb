# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :session
  attribute :account

  attribute :admin_user
  attribute :admin_session
  attribute :admin_account
end
