# frozen_string_literal: true

module AdminUsers
  class EmailConfirmationsController < ApplicationAdminController
    before_action :authenticate_admin_user!

    def new
      @email_confirmation = AdminUsers::EmailConfirmation.new(email: email_from_params)
    end

    def create
      @email_confirmation = AdminUsers::EmailConfirmation.new(email_confirmation_params)

      result = captcha_check(
        if_success_skip_paths: [
          admin_users_sign_up_path,
          admin_users_email_confirmation_path
        ]
      )

      if result.failure?
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      if @email_confirmation.invalid?
        flash.now[:alert] = @email_confirmation.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      result = AdminUsers::Create.new(@email_confirmation, request).call

      if result.success?
        redirect_to(
          root_path,
          info: "Email confirmation link has been sent to your email."
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(
        token: token_from_params,
        auto_click: auto_click_from_params
      )
    end

    def update
      @email_confirmation_edit = AdminUsers::EmailConfirmationEdit.new(email_confirmation_edit_params)

      if @email_confirmation_edit.invalid?
        flash.now[:info] = @email_confirmation_edit.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = AdminUsers::EmailConfirmations::Update.new(@email_confirmation_edit, request).call

      if result.success?
        admin_user = result.admin_user

        if signed_in_admin_user?
          redirect_to(
            admin_dashboard_path,
            success: "Email address has been confirmed."
          )
        elsif admin_user.password_digest.present?
          redirect_to(
            admin_users_sign_in_path,
            success: "Email address has been confirmed."
          )
        else
          redirect_to(
            new_admin_users_password_reset_path(email: admin_user.email),
            success: "Email address has been confirmed. Set a password for your account."
          )
        end
      else
        flash.now[:alert] = result.errors.full_messages
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def email_confirmation_params
      params.expect(admin_users_email_confirmation: [:email])
    end

    def email_confirmation_edit_params
      params.expect(admin_users_email_confirmation: [:token])
    end

    def email_from_params
      @email_from_params ||= params[:email].presence
    end

    def token_from_params
      @token_from_params ||= params[:token].presence
    end

    def auto_click_from_params
      @auto_click_from_params ||= params[:auto_click].presence
    end
  end
end
