# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Auth::AuthenticationControl
  include Auth::AuthorizationControl

  include AddFlashTypes
  include ManageCaptcha

  class InvalidQueryParamError < StandardError; end
end
