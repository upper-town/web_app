class ApplicationAdminApiController < ActionController::API
  include Auth::AdminApiAuthenticationControl
  include Auth::AdminApiAuthorizationControl
end
