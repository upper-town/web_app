# frozen_string_literal: true

class ApiController < ActionController::API
  include Auth::ApiAuthenticationControl
  include Auth::ApiAuthorizationControl
end
