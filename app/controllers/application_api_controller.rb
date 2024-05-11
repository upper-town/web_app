# frozen_string_literal: true

class ApplicationApiController < ActionController::Base
  include Auth::UserApiAuthenticationControl
  include Auth::UserApiAuthorizationControl
end
