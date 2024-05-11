# frozen_string_literal: true

module AdminUsers
  class SessionsController < ApplicationAdminUserController
    before_action :authenticate_admin_user!, only: [:destroy, :destroy_all]

    def new
      if signed_in_admin_user?
        redirect_to(
          admin_dashboard_path,
          notice: 'You are logged in already.'
        )

        return
      end

      @session = AdminUsers::Session.new
    end

    def create
      if signed_in_admin_user?
        redirect_to(
          admin_dashboard_path,
          notice: 'You are logged in already.'
        )
        return
      end

      @session = AdminUsers::Session.new(session_params)

      result = captcha_check(
        if_success_skip_paths: [
          admin_users_sign_in_path,
          admin_users_sessions_path
        ]
      )

      if result.failure?
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      if @session.invalid?
        flash.now[:alert] = @session.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      result = AdminUsers::AuthenticateSession.new(@session, request).call

      if result.success?
        sign_in_admin_user!(result.data[:admin_user], @session.remember_me)
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
      sign_out_admin_user!

      redirect_to(
        admin_users_sign_in_path,
        info: 'Your have been logged out.'
      )
    end

    def destroy_all
      # TODO: implement
    end

    private

    def session_params
      params
        .require(:admin_users_session)
        .permit(
          :email,
          :password,
          :remember_me
        )
    end
  end
end
