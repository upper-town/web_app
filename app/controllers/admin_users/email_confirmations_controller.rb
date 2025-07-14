# frozen_string_literal: true

module AdminUsers
  class EmailConfirmationsController < ApplicationAdminController
    skip_before_action :authenticate_admin_user!, only: [:edit, :update]

    before_action -> { set_email_confirmation(:create) }, only: [:new,  :create]
    before_action -> { set_email_confirmation(:update) }, only: [:edit, :update]

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
          admin_users_sign_up_path,
          admin_users_email_confirmation_path
        ])
      end,
      only: [:create]
    )

    def new
    end

    def create
      if @email_confirmation.invalid?
        flash.now[:alert] = @email_confirmation.errors
        render(:new, status: :unprocessable_entity)

        return
      end

      result = Create.new(@email_confirmation.email).call

      if result.success?
        flash[:info] = t("admin_users.email_confirmations.verification_code_sent")
        redirect_to(admin_admin_users_path)
      else
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
    end

    def update
      if @email_confirmation.invalid?
        flash.now[:alert] = @email_confirmation.errors
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = EmailConfirmations::Update.call(
        @email_confirmation.token,
        @email_confirmation.code
      )

      if result.success?
        flash[:notice] = t("admin_users.email_confirmations.email_address_confirmed")

        if signed_in_admin_user?
          redirect_to(admin_dashboard_path)
        elsif result.admin_user.password_digest.present?
          redirect_to(admin_users_sign_in_path)
        else
          flash[:info] = t("admin_users.email_confirmations.set_password_for_your_account")
          redirect_to(new_admin_users_password_reset_path)
        end
      else
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def set_email_confirmation(action)
      @email_confirmation = EmailConfirmation.new(permitted_params[:admin_users_email_confirmation])
      @email_confirmation.action = action
      @email_confirmation.token = permitted_params[:token].presence if @email_confirmation.token.blank?
    end

    def permitted_params
      params.permit(
        :token,
        admin_users_email_confirmation: [:email, :token, :code]
      )
    end
  end
end
