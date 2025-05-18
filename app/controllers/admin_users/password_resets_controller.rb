module AdminUsers
  class PasswordResetsController < ApplicationAdminController
    before_action :authenticate_admin_user!

    def new
      @password_reset = AdminUsers::PasswordReset.new(email: email_from_params)
    end

    def create
      @password_reset = AdminUsers::PasswordReset.new(password_reset_params)

      result = captcha_check(
        if_success_skip_paths: [
          new_admin_users_password_reset_path,
          admin_users_password_reset_path
        ]
      )

      if result.failure?
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      if @password_reset.invalid?
        flash.now[:alert] = @password_reset.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      result = AdminUsers::PasswordResets::Create.new(@password_reset, request).call

      if result.success?
        redirect_to(
          root_path,
          info: "Password reset link has been sent to your email."
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @password_reset_edit = AdminUsers::PasswordResetEdit.new(token: token_from_params)
    end

    def update
      @password_reset_edit = AdminUsers::PasswordResetEdit.new(password_reset_edit_params)

      if @password_reset_edit.invalid?
        flash.now[:alert] = @password_reset_edit.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = AdminUsers::PasswordResets::Update.new(@password_reset_edit, request).call

      if result.success?
        redirect_to(
          admin_users_sign_in_path,
          success: "Your password has been set."
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def token_from_params
      @token_from_params ||= params[:token].presence
    end

    def email_from_params
      @email_from_params ||= params[:email].presence
    end

    def password_reset_params
      params.expect(admin_users_password_reset: [ :email ])
    end

    def password_reset_edit_params
      params.expect(admin_users_password_reset_edit: [ :token, :password ])
    end
  end
end
