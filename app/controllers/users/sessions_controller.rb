# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    before_action :authenticate_user!, only: [:destroy, :destroy_all]

    def new
      if signed_in_user?
        redirect_to(
          inside_dashboard_path,
          notice: "You are logged in already."
        )
        return
      end

      @session = Users::Session.new
    end

    def create
      if signed_in_user?
        redirect_to(
          inside_dashboard_path,
          notice: "You are logged in already."
        )
        return
      end

      @session = Users::Session.new(session_params)

      result = captcha_check(if_success_skip_paths: [users_sign_in_path, users_sessions_path])

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

      result = Users::AuthenticateSession.new(@session).call

      if result.success?
        sign_in_user!(result.user, @session.remember_me)
        return_to_url = consume_return_to

        redirect_to(
          return_to_url || inside_dashboard_path,
          success: "You are logged in."
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def destroy
      sign_out_user!

      redirect_to(
        root_path,
        info: "Your have been logged out."
      )
    end

    def destroy_all
      # TODO: implement
    end

    private

    def session_params
      params.expect(users_session: [
        :email,
        :password,
        :remember_me
      ])
    end
  end
end
