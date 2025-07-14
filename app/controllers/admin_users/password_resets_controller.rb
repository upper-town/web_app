# frozen_string_literal: true

module AdminUsers
  class PasswordResetsController < ApplicationAdminController
    skip_before_action :authenticate_admin_user!

    before_action -> { set_password_reset(:create) }, only: [:new,  :create]
    before_action -> { set_password_reset(:update) }, only: [:edit, :update]

    rate_limit(
      to: 6,
      within: 1.minute,
      with: -> { render_rate_limited(:new) },
      name: "create",
      only: [:create]
    )
    rate_limit(
      to: 6,
      within: 1.minute,
      with: -> { render_rate_limited(:edit) },
      name: "update",
      only: [:update]
    )

    before_action(
      -> do
        check_captcha_and_render(:new, if_success_skip_paths: [
          new_admin_users_password_reset_path,
          admin_users_password_reset_path
        ])
      end,
      only: [:create]
    )

    def new
    end

    def create
      if @password_reset.invalid?
        flash.now[:alert] = @password_reset.errors
        render(:new, status: :unprocessable_entity)

        return
      end

      result = PasswordResets::Create.call(@password_reset.email)

      flash[:info] = t("admin_users.password_resets.verification_code_sent")

      if result.success?
        password_reset_token = result.admin_user.generate_token!(:password_reset)
        redirect_to(edit_admin_users_password_reset_path(token: password_reset_token))
      else
        dummy_token, _, _ = TokenGenerator::Admin.generate
        redirect_to(edit_admin_users_password_reset_path(token: dummy_token))
      end
    end

    def edit
    end

    def update
      if @password_reset.invalid?
        flash.now[:alert] = @password_reset.errors
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = PasswordResets::Update.call(
        @password_reset.token,
        @password_reset.code,
        @password_reset.password
      )

      if result.success?
        flash[:notice] = t("admin_users.password_resets.password_set")
        redirect_to(signed_in_admin_user? ? admin_dashboard_path : admin_users_sign_in_path)
      else
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def set_password_reset(action)
      @password_reset = PasswordReset.new(permitted_params[:admin_users_password_reset])
      @password_reset.action = action
      @password_reset.token = permitted_params[:token].presence if @password_reset.token.blank?
    end

    def permitted_params
      params.permit(
        :token,
        admin_users_password_reset: [:email, :token, :code, :password]
      )
    end
  end
end
