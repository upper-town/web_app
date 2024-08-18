# frozen_string_literal: true

class ApplicationAdminController < ActionController::Base
  include Auth::AdminAuthenticationControl
  include Auth::AdminAuthorizationControl

  include AddFlashTypes
  include ManageCaptcha

  class InvalidQueryParamError < StandardError; end

  layout 'admin'
end
