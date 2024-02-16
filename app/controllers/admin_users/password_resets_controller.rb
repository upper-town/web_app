# frozen_string_literal: true

module AdminUsers
  class PasswordResetsController < ApplicationAdminController
    before_action :authenticate_admin_user!

    def new
      @new_form = AdminUsers::PasswordReset::NewForm.new(email: email_from_params)
    end

    def create
      @new_form = AdminUsers::PasswordReset::NewForm.new(new_form_params)

      result = captcha_check(if_success_skip_paths: [new_admin_users_password_reset_path, admin_users_password_reset_path])

      if result.failure?
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      if @new_form.invalid?
        flash.now[:alert] = @new_form.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      result = AdminUsers::PasswordReset::Create.new(@new_form.attributes, request).call

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
      @edit_form = AdminUsers::PasswordReset::EditForm.new(token: token_from_params)
    end

    def update
      @edit_form = AdminUsers::PasswordReset::EditForm.new(edit_form_params)

      if @edit_form.invalid?
        flash.now[:alert] = @edit_form.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = AdminUsers::PasswordReset::Update.new(@edit_form.attributes, request).call

      if result.success?
        redirect_to(
          admin_users_sign_in_path,
          success: 'Your password has been set.'
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def token_from_params
      @token_from_params ||= params['token'].presence
    end

    def email_from_params
      @email_from_params ||= params['email'].presence
    end

    def new_form_params
      params.require('admin_users_password_reset_new_form').permit('email')
    end

    def edit_form_params
      params.require('admin_users_password_reset_edit_form').permit('token', 'password')
    end
  end
end
