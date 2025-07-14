# frozen_string_literal: true

module AdminUsers
  class SessionsController < ApplicationAdminController
    skip_before_action :authenticate_admin_user!, only: [:new, :create]

    before_action :set_session,             only: [:new, :create]
    before_action :check_already_logged_in, only: [:new, :create]

    rate_limit(
      to: 6,
      within: 1.minute,
      with: -> { render_rate_limited(:new) },
      name: "create",
      only: [:create]
    )

    before_action(
      -> do
        check_captcha_and_render(:new, if_success_skip_paths: [
          admin_users_sign_in_path,
          admin_users_sessions_path
        ])
      end,
      only: [:create]
    )

    def new
    end

    def create
      if @session.invalid?
        flash.now[:alert] = @session.errors
        render(:new, status: :unprocessable_entity)

        return
      end

      result = AuthenticateSession.call(
        @session.email,
        @session.password
      )

      if result.success?
        sign_in_admin_user!(result.admin_user, @session.remember_me)
        return_to_url = consume_return_to

        flash[:notice] = t("admin_users.sessions.logged_in")
        redirect_to(return_to_url || admin_dashboard_path)
      else
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def destroy
      sign_out_admin_user!

      flash[:info] = t("admin_users.sessions.logged_out")
      redirect_to(admin_users_sign_in_path)
    end

    def destroy_all
      sign_out_admin_user!(destroy_all: true)

      flash[:info] = t("admin_users.sessions.logged_out_all")
      redirect_to(admin_users_sign_in_path)
    end

    private

    def check_already_logged_in
      if signed_in_admin_user?
        flash[:info] = t("admin_users.sessions.logged_in_already")
        redirect_to(admin_dashboard_path)
      end
    end

    def set_session
      @session = Session.new(permitted_params[:admin_users_session])
    end

    def permitted_params
      params.permit(admin_users_session: [:email, :password, :remember_me])
    end
  end
end
