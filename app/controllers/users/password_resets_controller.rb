# frozen_string_literal: true

module Users
  class PasswordResetsController < ApplicationController
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

      result = PasswordResets::Create.new(@user.email).call

      flash[:info] = t("info.verification_code_sent")

      if result.success?
        password_reset_token = result.user.generate_token!(:password_reset)
        redirect_to(edit_users_password_reset_path(token: password_reset_token))
      else
        dummy_token = TokenGenerator.generate
        redirect_to(edit_users_password_reset_path(token: dummy_token))
      end
    end

    def edit
      @password_reset = PasswordReset.new(token: token_from_params)
    end

    def update
      @password_reset = PasswordReset.new(password_reset_params)

      if @password_reset.invalid?
        flash.now[:alert] = @password_reset.errors
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = PasswordResets::Update.new(
        @password_reset.token,
        @password_reset.code,
        @password_reset.password
      ).call

      if result.success?
        flash[:notice] = t("notice.password_set")
        redirect_to(signed_in_user? ? inside_dashboard_path : users_sign_in_path)
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
          new_users_password_reset_path,
          users_password_reset_path
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

    def password_reset_params
      params.expect(users_password_reset: [:token, :code, :password])
    end

    def token_from_params
      @token_from_params ||= params["token"].presence
    end
  end
end
