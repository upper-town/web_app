# frozen_string_literal: true

class ApplicationAdminUserApiController < ActionController::API
  include Auth::AdminApiAuthenticationControl
  include Auth::AdminApiAuthorizationControl
end
