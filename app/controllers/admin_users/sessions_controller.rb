# frozen_string_literal: true

module AdminUsers
  class SessionsController < ApplicationAdminController
    before_action :authenticate_admin_user!, only: [:destroy, :destroy_all]

    def new
      if signed_in?
        redirect_to(
          admin_dashboard_path,
          notice: 'You are logged in already.'
        )

        return
      end

      @new_form = AdminUsers::Sessions::NewForm.new
    end

    def create
      if signed_in?
        redirect_to(
          admin_dashboard_path,
          notice: 'You are logged in already.'
        )
        return
      end

      @new_form = AdminUsers::Sessions::NewForm.new(new_form_params)

      result = captcha_check(if_success_skip_paths: [admin_users_sign_in_path, admin_users_sessions_path])

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

      result = AdminUsers::AuthenticateSession.new(@new_form.attributes, request).call

      if result.success?
        sign_in!(result.data[:admin_user], @new_form.remember_me)
        return_to = consume_return_to

        redirect_to(
          return_to || admin_dashboard_path,
          success: 'You are logged in.'
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def destroy
      sign_out!

      redirect_to(
        admin_users_sign_in_path,
        info: 'Your have been logged out.'
      )
    end

    def destroy_all
      # TODO: implement
    end

    private

    def new_form_params
      params
        .require('admin_users_sessions_new_form')
        .permit(
          'email',
          'password',
          'remember_me'
        )
    end
  end
end
