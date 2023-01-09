# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Override Devise's after_sign_in_path_for
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      root_path
    elsif resource.is_a?(AdminUser)
      admin_dashboard_path
    else
      super
    end
  end
end
