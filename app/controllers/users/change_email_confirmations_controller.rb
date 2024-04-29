# frozen_string_literal: true

module Users
  class ChangeEmailConfirmationsController < ApplicationController
    def edit
      @change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(
        token: token_from_params,
        auto_click: auto_click_from_params
      )
    end

    def update
      @change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(change_email_confirmation_edit_params)

      if @change_email_confirmation_edit.invalid?
        flash.now[:alert] = @change_email_confirmation_edit.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = Users::ChangeEmailConfirmations::Update.new(@change_email_confirmation_edit, request).call

      if result.success?
        redirect_to(
          signed_in? ? inside_dashboard_path : root_path,
          success: 'Email address has been changed.'
        )
      else
        flash.now[:alert] = result.errors.full_messages
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def change_email_confirmation_edit_params
      params.require(:users_change_email_confirmation_edit).permit(:token)
    end

    def token_from_params
      @token_from_params ||= params[:token].presence
    end

    def auto_click_from_params
      @auto_click_from_params ||= params[:auto_click].presence
    end
  end
end
