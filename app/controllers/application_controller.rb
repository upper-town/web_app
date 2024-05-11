# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Auth::UserAuthenticationControl
  include Auth::UserAuthorizationControl

  include AddFlashTypes
  include ManageCaptcha

  class InvalidQueryParamError < StandardError; end
end
