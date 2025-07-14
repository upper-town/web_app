# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :ensure_rails_session

  include Auth::AuthenticationControl
  include Auth::AuthorizationControl

  include AddFlashTypes
  include ManageCaptcha
  include ManageRateLimit

  class InvalidQueryParamError < StandardError; end

  # Only allow modern browsers supporting webp images, web push, badges,
  # import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout "application"

  private

  def ensure_rails_session
    session["_force"] ||= true
  end
end
