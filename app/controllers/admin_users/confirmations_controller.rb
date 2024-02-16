# frozen_string_literal: true

module AdminUsers
  class ConfirmationsController < ApplicationAdminController
    before_action :authenticate_admin_user!

    def new
      @new_form = AdminUsers::Confirmation::NewForm.new(email: email_from_params)
    end

    def create
      @new_form = AdminUsers::Confirmation::NewForm.new(new_form_params)

      result = captcha_check(if_success_skip_paths: [admin_users_sign_up_path, admin_users_confirmation_path])

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

      result = AdminUsers::Create.new(@new_form.attributes, request).call

      if result.success?
        redirect_to(
          root_path,
          info: 'Confirmation link has been sent to your email.'
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @edit_form = AdminUsers::Confirmation::EditForm.new(
        token: token_from_params,
        auto_click: auto_click_from_params
      )
    end

    def update
      @edit_form = AdminUsers::Confirmation::EditForm.new(edit_form_params)

      if @edit_form.invalid?
        flash.now[:info] = @edit_form.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = AdminUsers::Confirmation::Update.new(@edit_form.attributes, request).call

      if result.success?
        admin_user = result.data[:admin_user]

        if signed_in?
          redirect_to(
            admin_dashboard_path,
            success: 'Email address has been confirmed.'
          )
        elsif admin_user.password_digest.present?
          redirect_to(
            admin_users_sign_in_path,
            success: 'Email address has been confirmed.'
          )
        else
          redirect_to(
            new_admin_users_password_reset_path(email: admin_user.email),
            success: 'Email address has been confirmed. Set a password for your account.'
          )
        end
      else
        flash.now[:alert] = result.errors.full_messages
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def new_form_params
      params.require('admin_users_confirmation_new_form').permit('email')
    end

    def edit_form_params
      params.require('admin_users_confirmation_edit_form').permit('token')
    end

    def email_from_params
      @email_from_params ||= params['email'].presence
    end

    def token_from_params
      @token_from_params ||= params['token'].presence
    end

    def auto_click_from_params
      @auto_click_from_params ||= params['auto_click'].presence
    end
  end
end
