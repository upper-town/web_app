# frozen_string_literal: true

class ApplicationController < ActionController::Base
  class InvalidQueryParamError < StandardError; end

  # Override Devise's after_sign_in_path_for
  def after_sign_in_path_for(resource)
    case resource
    when User
      root_path
    when AdminUser
      admin_dashboard_path
    else
      super
    end
  end
end
