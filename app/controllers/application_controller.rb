# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Auth::AuthenticationControl
  include Auth::AuthorizationControl

  include AddFlashTypes
  include ManageCaptcha

  class InvalidQueryParamError < StandardError; end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
