# frozen_string_literal: true

class ApplicationApiAdminController < ActionController::API
  include Auth::ApiAdminAuthenticationControl
  include Auth::ApiAdminAuthorizationControl
end
