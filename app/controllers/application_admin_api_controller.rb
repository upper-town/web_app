# frozen_string_literal: true

class ApplicationAdminApiController < ActionController::Base
  include Auth::AdminApiAuthenticationControl
  include Auth::AdminApiAuthorizationControl
end
