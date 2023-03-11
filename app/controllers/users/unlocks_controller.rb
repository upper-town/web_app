# frozen_string_literal: true

module Users
  class UnlocksController < Devise::UnlocksController
    # GET /resource/unlock/new
    def new
      @captcha = Captcha.new

      super
    end

    # POST /resource/unlock
    def create
      devise_unlocks_build_resource
      @captcha = Captcha.new

      result = Users::CheckBeforeUnlocks.new(@captcha, request).call

      if result.success?
        devise_unlocks_create
      else
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    # GET /resource/unlock?unlock_token=abcdef
    # def show
    #   super
    # end

    # protected

    # The path used after sending unlock password instructions
    # def after_sending_unlock_instructions_path_for(resource)
    #   super(resource)
    # end

    # The path used after unlocking the resource
    # def after_unlock_path_for(resource)
    #   super(resource)
    # end

    private

    def devise_unlocks_build_resource
      self.resource = resource_class.new
    end

    # Based on Devise::UnlocksController#create
    def devise_unlocks_create
      self.resource = resource_class.send_unlock_instructions(resource_params)

      if successfully_sent?(resource)
        respond_with({}, location: after_sending_unlock_instructions_path_for(resource))
      else
        respond_with(resource)
      end
    end
  end
end
