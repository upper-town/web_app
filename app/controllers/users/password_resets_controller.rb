# frozen_string_literal: true

module Users
  class PasswordResetsController < ApplicationController
    def new
      @password_reset = Users::PasswordReset.new(email: email_from_params)
    end

    def create
      @password_reset = Users::PasswordReset.new(password_reset_params)

      result = captcha_check(
        if_success_skip_paths: [
          new_users_password_reset_path,
          users_password_reset_path
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

      result = Users::PasswordResets::Create.new(@password_reset, request).call

      if result.success?
        redirect_to(
          root_path,
          info: 'Password reset link has been sent to your email.'
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @password_reset_edit = Users::PasswordResetEdit.new(token: token_from_params)
    end

    def update
      @password_reset_edit = Users::PasswordResetEdit.new(password_reset_edit_params)

      if @password_reset_edit.invalid?
        flash.now[:alert] = @password_reset_edit.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = Users::PasswordResets::Update.new(@password_reset_edit, request).call

      if result.success?
        redirect_to(
          signed_in_user? ? inside_dashboard_path : users_sign_in_path,
          success: 'Your password has been set.'
        )
      else
        flash.now[:alert] = result.errors.full_messages
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
      params.require(:users_password_reset).permit(:email)
    end

    def password_reset_edit_params
      params.require(:users_password_reset_edit).permit(:token, :password)
    end
  end
end
