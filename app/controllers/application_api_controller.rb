class ApplicationApiController < ActionController::API
  include Auth::ApiAuthenticationControl
  include Auth::ApiAuthorizationControl
end
