# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /resource/confirmation/new
    def new
      @captcha = Captcha.new

      super
    end

    # POST /resource/confirmation
    def create
      devise_confirmations_build_resource
      @captcha = Captcha.new

      result = Users::CheckBeforeConfirmations.new(@captcha, request).call

      if result.success?
        devise_confirmations_create
      else
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    # GET /resource/confirmation?confirmation_token=abcdef
    # def show
    #   super
    # end

    # protected

    # The path used after resending confirmation instructions.
    # def after_resending_confirmation_instructions_path_for(resource_name)
    #   super(resource_name)
    # end

    # The path used after confirmation.
    # def after_confirmation_path_for(resource_name, resource)
    #   super(resource_name, resource)
    # end

    private

    def devise_confirmations_build_resource
      self.resource = resource_class.new
    end

    # Based on Devise::ConfirmationsController#create
    def devise_confirmations_create
      self.resource = resource_class.send_confirmation_instructions(resource_params)

      if successfully_sent?(resource)
        respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
      else
        respond_with(resource)
      end
    end
  end
end
