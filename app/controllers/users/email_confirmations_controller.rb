# frozen_string_literal: true

module Users
  class EmailConfirmationsController < ApplicationController
    def new
      @new_form = Users::EmailConfirmation::NewForm.new(email: email_from_params)
    end

    def create
      @new_form = Users::EmailConfirmation::NewForm.new(new_form_params)

      result = captcha_check(if_success_skip_paths: [users_sign_up_path, users_email_confirmation_path])

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

      result = Users::Create.new(@new_form.attributes, request).call

      if result.success?
        redirect_to(
          root_path,
          info: 'Email confirmation link has been sent to your email.'
        )
      else
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @edit_form = Users::EmailConfirmation::EditForm.new(
        token: token_from_params,
        auto_click: auto_click_from_params
      )
    end

    def update
      @edit_form = Users::EmailConfirmation::EditForm.new(edit_form_params)

      if @edit_form.invalid?
        flash.now[:alert] = @edit_form.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = Users::EmailConfirmation::Update.new(@edit_form.attributes, request).call

      if result.success?
        user = result.data[:user]

        if signed_in?
          redirect_to(
            inside_dashboard_path,
            success: 'Email address has been confirmed.'
          )
        elsif user.password_digest.present?
          redirect_to(
            users_sign_in_path,
            success: 'Email address has been confirmed.'
          )
        else
          password_reset_token = user.regenerate_token!(:password_reset)

          redirect_to(
            edit_users_password_reset_path(token: password_reset_token),
            success: 'Email address has been confirmed.',
            notice: 'Set a password for your account.'
          )
        end
      else
        flash.now[:alert] = result.errors.full_messages
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def new_form_params
      params.require('users_email_confirmation_new_form').permit('email')
    end

    def edit_form_params
      params.require('users_email_confirmation_edit_form').permit('token')
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
