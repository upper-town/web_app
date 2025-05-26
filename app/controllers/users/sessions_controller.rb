# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    before_action :check_already_logged_in, only: [:new, :create]
    before_action :authenticate_user!, only: [:destroy, :destroy_all]

    rate_limit(
      to: 4,
      within: 1.minute,
      with: -> { rate_limit_for_create },
      name: "create",
      only: :create
    )

    before_action :captcha_for_create, only: :create

    def new
      @session = Users::Session.new
    end

    def create
      set_session_for_create

      if @session.invalid?
        flash.now[:alert] = @session.errors
        render(:new, status: :unprocessable_entity)

        return
      end

      result = AuthenticateSession.new(
        @session.email,
        @session.password
      ).call

      if result.success?
        sign_in_user!(result.user, @session.remember_me)
        return_to_url = consume_return_to

        flash[:notice] = t("notice.logged_in")
        redirect_to(return_to_url || inside_dashboard_path)
      else
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def destroy
      sign_out_user!

      flash[:info] = t("notice.logged_out")
      redirect_to(root_path)
    end

    def destroy_all
      sign_out_user!(destroy_all: true)

      flash[:info] = t("notice.logged_out_all")
      redirect_to(root_path)
    end

    private

    def check_already_logged_in
      if signed_in_user?
        flash[:info] = t("info.logged_in_already")
        redirect_to(inside_dashboard_path)
      end
    end

    def rate_limit_for_create
      set_session_for_create

      flash.now[:alert] = t("alert.please_try_again_later_too_many_requests")
      render(:new, status: :unprocessable_entity)
    end

    def captcha_for_create
      set_session_for_create

      result = captcha_check(
        if_success_skip_paths: [
          users_sign_in_path,
          users_sessions_path
        ]
      )

      if result.failure?
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def set_session_for_create
      @session = Users::Session.new(session_params)
    end

    def session_params
      params.expect(users_session: [:email, :password, :remember_me])
    end
  end
end
