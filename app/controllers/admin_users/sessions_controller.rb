# frozen_string_literal: true

module AdminUsers
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    def new
      @captcha = Captcha.new

      super
    end

    # POST /resource/sign_in
    def create
      devise_sessions_build_resource
      @captcha = Captcha.new

      result = AdminUsers::CheckBeforeSessions.new(@captcha, request).call

      if result.success?
        devise_sessions_create
      else
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end

    private

    def devise_sessions_build_resource
      self.resource = resource_class.new(sign_in_params)
    end

    def devise_sessions_create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end
end
