# frozen_string_literal: true

module AdminUsers
  class PasswordsController < Devise::PasswordsController
    # GET /resource/password/new
    def new
      @captcha = Captcha.new

      super
    end

    # POST /resource/password
    def create
      devise_passwords_build_resource
      @captcha = Captcha.new

      result = AdminUsers::CheckBeforePasswords.new(@captcha, request).call

      if result.success?
        devise_passwords_create
      else
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    # def edit
    #   super
    # end

    # PUT /resource/password
    # def update
    #   super
    # end

    # protected

    # def after_resetting_password_path_for(resource)
    #   super(resource)
    # end

    # The path used after sending reset password instructions
    # def after_sending_reset_password_instructions_path_for(resource_name)
    #   super(resource_name)
    # end

    private

    def devise_passwords_build_resource
      self.resource = resource_class.new
    end

    def devise_passwords_create
      self.resource = resource_class.send_reset_password_instructions(resource_params)

      if successfully_sent?(resource)
        respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      else
        respond_with(resource)
      end
    end
  end
end
