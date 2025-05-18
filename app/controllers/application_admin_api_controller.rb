# frozen_string_literal: true

class ApplicationAdminApiController < ActionController::API
  include Auth::AdminApiAuthenticationControl
  include Auth::AdminApiAuthorizationControl
end
