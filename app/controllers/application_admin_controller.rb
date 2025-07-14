# frozen_string_literal: true

class ApplicationAdminController < ActionController::Base
  before_action :ensure_rails_session
  before_action :authenticate_admin_user!

  include Auth::AdminAuthenticationControl
  include Auth::AdminAuthorizationControl

  include AddFlashTypes
  include ManageCaptcha
  include ManageRateLimit

  class InvalidQueryParamError < StandardError; end

  # Only allow modern browsers supporting webp images, web push, badges,
  # import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout "application_admin"

  private

  def ensure_rails_session
    session["_force"] ||= true
  end

  def captcha_widget_tag(*, **)
    super(*, theme: "light", **)
  end
end
