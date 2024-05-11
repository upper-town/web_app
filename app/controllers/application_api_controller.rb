# frozen_string_literal: true

class ApplicationApiController < ActionController::API
  include Auth::UserApiAuthenticationControl
  include Auth::UserApiAuthorizationControl
end
