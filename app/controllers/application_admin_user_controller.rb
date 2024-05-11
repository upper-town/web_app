# frozen_string_literal: true

class ApplicationAdminUserController < ActionController::Base
  include Auth::AdminUserAuthenticationControl
  include Auth::AdminUserAuthorizationControl

  include AddFlashTypes
  include ManageCaptcha

  class InvalidQueryParamError < StandardError; end

  layout 'admin'
end
