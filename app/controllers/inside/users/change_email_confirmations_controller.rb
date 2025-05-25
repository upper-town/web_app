# frozen_string_literal: true

module Inside
  module Users
    class ChangeEmailConfirmationsController < BaseController
      def new
        @change_email_confirmation = ::Users::ChangeEmailConfirmation.new
      end

      def create
        @change_email_confirmation = ::Users::ChangeEmailConfirmation.new(change_email_confirmation_params)

        result = captcha_check(
          if_success_skip_paths: [
            new_inside_user_change_email_confirmation_path,
            inside_user_change_email_confirmation_path
          ]
        )

        if result.failure?
          flash.now[:alert] = result.errors.full_messages
          render(:new, status: :unprocessable_entity)

          return
        end

        if @change_email_confirmation.invalid?
          render(:new, status: :unprocessable_entity)

          return
        end

        result = ::Users::ChangeEmailConfirmations::Create
          .new(@change_email_confirmation, current_user.email).call

        if result.success?
          redirect_to(
            inside_account_path,
            success: "Your request to change email address has been created."
          )
        else
          flash.now[:alert] = result.errors.full_messages
          render(:new, status: :unprocessable_entity)
        end
      end

      private

      def change_email_confirmation_params
        params.expect(users_change_email_confirmation: [
          :email,
          :change_email,
          :password
        ])
      end
    end
  end
end
