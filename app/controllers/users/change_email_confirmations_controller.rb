# frozen_string_literal: true

module Users
  class ChangeEmailConfirmationsController < ApplicationController
    before_action :authenticate_user!, only: [:new, :create]

    before_action -> { set_change_email_confirmation(:create) }, only: [:new,  :create]
    before_action -> { set_change_email_confirmation(:update) }, only: [:edit, :update]

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
          new_users_change_email_confirmation_path,
          users_change_email_confirmation_path
        ])
      end,
      only: [:create]
    )

    def new
    end

    def create
      if @change_email_confirmation.invalid?
        flash.now[:alert] = @change_email_confirmation.errors
        render(:new, status: :unprocessable_entity)

        return
      end

      result = ChangeEmailConfirmations::Create.call(
        @change_email_confirmation.email,
        @change_email_confirmation.change_email,
        @change_email_confirmation.password,
        current_user.email
      )

      if result.success?
        change_email_confirmation_token = result.user.generate_token!(:change_email_confirmation)

        flash[:success] = t("users.change_email_confirmations.verification_code_sent")
        redirect_to(edit_users_change_email_confirmation_path(token: change_email_confirmation_token))
      else
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
    end

    def update
      if @change_email_confirmation.invalid?
        flash.now[:alert] = @change_email_confirmation.errors
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = ChangeEmailConfirmations::Update.call(
        @change_email_confirmation.token,
        @change_email_confirmation.code
      )

      if result.success?
        flash[:success] = t("users.change_email_confirmations.email_address_changed")
        redirect_to(signed_in_user? ? inside_dashboard_path : root_path)
      else
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def set_change_email_confirmation(action)
      @change_email_confirmation = ChangeEmailConfirmation.new(
        permitted_params[:users_change_email_confirmation]
      )
      @change_email_confirmation.action = action

      if @change_email_confirmation.token.blank?
        @change_email_confirmation.token = permitted_params[:token].presence
      end
    end

    def permitted_params
      params.permit(
        :token,
        users_change_email_confirmation: [
          :email,
          :change_email,
          :password,
          :token,
          :code
        ]
      )
    end
  end
end
