# frozen_string_literal: true

class ApplicationAdminApiController < ActionController::Base
  include Auth::ApiAuthenticationControl
  include Auth::ApiAuthorizationControl
end
