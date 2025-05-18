class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user
  attribute :account

  attribute :api_session

  attribute :admin_session
  attribute :admin_user
  attribute :admin_account

  attribute :admin_api_session
end
