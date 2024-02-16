# frozen_string_literal: true

class ApplicationApiController < ActionController::Base
  include Auth::ApiAuthenticationControl
  include Auth::ApiAuthorizationControl
end
