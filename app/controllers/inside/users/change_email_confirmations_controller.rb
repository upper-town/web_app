# frozen_string_literal: true

module Inside
  module Users
    class ChangeEmailConfirmationsController < BaseController
      def new
        @new_form = ChangeEmailConfirmation::NewForm.new
      end

      def create
        @new_form = ChangeEmailConfirmation::NewForm.new(change_email_params)

        result = captcha_check(if_success_skip_paths: [
          new_inside_user_change_email_confirmation_path,
          inside_user_change_email_confirmation_path
        ])

        if result.failure?
          flash.now[:alert] = result.errors.full_messages
          render(:new, status: :unprocessable_entity)

          return
        end

        if @new_form.invalid?
          flash.now[:alert] = @new_form.errors.full_messages
          render(:new, status: :unprocessable_entity)

          return
        end

        result = ::Users::ChangeEmailConfirmation::Create.new(@new_form.attributes, current_user.email, request).call

        if result.success?
          redirect_to(
            inside_user_account_path,
            success: 'Your request to change email address has been created.'
          )
        else
          flash.now[:alert] = result.errors.full_messages
          render(:new, status: :unprocessable_entity)
        end
      end

     private

      def change_email_params
        params
          .require('inside_users_change_email_confirmation_new_form')
          .permit(
            'email',
            'change_email',
            'password'
          )
      end
    end
  end
end
