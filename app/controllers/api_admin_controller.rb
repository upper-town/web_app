# frozen_string_literal: true

class ApiAdminController < ActionController::API
  include Auth::ApiAdminAuthenticationControl
  include Auth::ApiAdminAuthorizationControl
end
