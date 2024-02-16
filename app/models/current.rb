# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :auth_model_active_session
  attribute :auth_model
  attribute :auth_model_account
end
