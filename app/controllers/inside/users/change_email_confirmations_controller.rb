# frozen_string_literal: true

module Inside
  module Users
    class ChangeEmailConfirmationsController < BaseController
      rate_limit(
        to: 2,
        within: 5.minutes,
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
          flash.now[:alert] = @user.errors.full_messages_for(:base)
          render(:new, status: :unprocessable_entity)

          return
        end

        result = ::Users::ChangeEmailConfirmations::Create.new(
          @user.email,
          @user.change_email,
          @user.password,
          current_user.email
        ).call

        if result.success?
          change_email_confirmation_token = result.user.generate_token!(:change_email_confirmation)

          redirect_to(
            edit_inside_users_email_confirmation_path(token: change_email_confirmation_token),
            success: "Verification code has been sent to your email"
          )
        else
          flash.now[:alert] = result.errors
          render(:new, status: :unprocessable_entity)
        end
      end

      def edit
        @change_email_confirmation = ChangeEmailConfirmation.new(token: token_from_params)
      end

      def update
        @change_email_confirmation = ChangeEmailConfirmation.new(change_email_confirmation_params)

        if @change_email_confirmation.invalid?
          flash.now[:alert] = @change_email_confirmation.errors.full_messages_for(:base)
          render(:edit, status: :unprocessable_entity)

          return
        end

        result = ChangeEmailConfirmations::Update.new(
          @change_email_confirmation.token,
          @change_email_confirmation.code
        ).call

        if result.success?
          redirect_to(
            signed_in_user? ? inside_dashboard_path : root_path,
            success: "Email address has been changed."
          )
        else
          flash.now[:alert] = result.errors
          render(:edit, status: :unprocessable_entity)
        end
      end

      private

      def rate_limit_for_create
        set_user_for_create

        flash.now[:alert] = "Please try again later. Too many requests."
        render(:new, status: :unprocessable_entity)
      end

      def captcha_for_create
        set_user_for_create

        result = captcha_check(
          if_success_skip_paths: [
            new_inside_user_change_email_confirmation_path,
            inside_user_change_email_confirmation_path
          ]
        )

        if result.failure?
          flash.now[:alert] = result.errors
          render(:new, status: :unprocessable_entity)
        end
      end

      def set_user_for_create
        @user = User.new(user_params)
      end

      def user_params
        params.expect(user: [
          :email,
          :change_email,
          :password
        ])
      end
    end
  end
end
