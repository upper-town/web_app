# frozen_string_literal: true

module Users
  class EmailConfirmationsController < ApplicationController
    rate_limit(
      to: 4,
      within: 1.minute,
      with: -> { rate_limit_for_create },
      name: "create",
      only: :create
    )

    before_action :captcha_for_create, only: :create

    def new
      @user = User.new
    end

    def create
      set_user_for_create

      if @user.invalid?
        flash.now[:alert] = @user.errors
        render(:new, status: :unprocessable_entity)

        return
      end

      result = Create.new(@user.email).call

      if result.success?
        email_confirmation_token = result.user.generate_token!(:email_confirmation)

        flash[:info] = t("info.verification_code_sent")
        redirect_to(edit_users_email_confirmation_path(token: email_confirmation_token))
      else
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
      @email_confirmation = EmailConfirmation.new(token: token_from_params)
    end

    def update
      @email_confirmation = EmailConfirmation.new(email_confirmation_params)

      if @email_confirmation.invalid?
        flash.now[:alert] = @email_confirmation.errors
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = EmailConfirmations::Update.new(
        @email_confirmation.token,
        @email_confirmation.code
      ).call

      if result.success?
        flash[:notice] = t("notice.email_address_confirmed")

        if signed_in_user?
          redirect_to(inside_dashboard_path)
        elsif result.user.password_digest.present?
          redirect_to(users_sign_in_path)
        else
          flash[:info] = t("info.set_password_for_your_account")
          redirect_to(new_users_password_reset_path)
        end
      else
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def rate_limit_for_create
      set_user_for_create

      flash.now[:alert] = t("alert.please_try_again_later_too_many_requests")
      render(:new, status: :unprocessable_entity)
    end

    def captcha_for_create
      set_user_for_create

      result = captcha_check(
        if_success_skip_paths: [
          users_sign_up_path,
          users_email_confirmation_path
        ]
      )

      if result.failure?
        flash.now[:alert] = result.errors
        render(:new, status: :unprocessable_entity)
      end
    end

    def set_user_for_create
      @user = User.new(user_params)
      @user.skip_email_uniqueness_validation = true
    end

    def user_params
      params.expect(user: [:email])
    end

    def email_confirmation_params
      params.expect(users_email_confirmation: [:token, :code])
    end

    def token_from_params
      @token_from_params ||= params["token"].presence
    end
  end
end
