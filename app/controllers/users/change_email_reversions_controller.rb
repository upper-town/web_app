# frozen_string_literal: true

module Users
  class ChangeEmailReversionsController < ApplicationController
    def edit
      @change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(
        token: token_from_params,
        auto_click: auto_click_from_params
      )
    end

    def update
      @change_email_reversion_edit = Users::ChangeEmailReversionEdit.new(change_email_reversion_params)

      if @change_email_reversion_edit.invalid?
        flash.now[:alert] = @change_email_reversion_edit.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = Users::ChangeEmailReversions::Update.new(@change_email_reversion_edit).call

      if result.success?
        redirect_to(
          signed_in_user? ? inside_dashboard_path : root_path,
          success: "Email address has been restored."
        )
      else
        flash.now[:alert] = result.errors.full_messages
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def change_email_reversion_params
      params.expect(users_change_email_reversion: [:token])
    end

    def token_from_params
      @token_from_params ||= params[:token].presence
    end

    def auto_click_from_params
      @auto_click_from_params ||= params[:auto_click].presence
    end
  end
end
