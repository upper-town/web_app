# frozen_string_literal: true

module Users
  class ChangeEmailReversionsController < ApplicationController
    def edit
      @edit_form = Users::ChangeEmailReversion::EditForm.new(
        token: token_from_params,
        auto_click: auto_click_from_params
      )
    end

    def update
      @edit_form = Users::ChangeEmailReversion::EditForm.new(edit_form_params)

      if @edit_form.invalid?
        flash.now[:alert] = @edit_form.errors.full_messages
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = Users::ChangeEmailReversion::Update.new(@edit_form.attributes, request).call

      if result.success?
        redirect_to(
          signed_in? ? inside_dashboard_path : root_path,
          success: 'Email address has been restored.'
        )
      else
        flash.now[:alert] = result.errors.full_messages
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def edit_form_params
      params.require('users_change_email_reversion_edit_form').permit('token')
    end

    def token_from_params
      @token_from_params ||= params['token'].presence
    end

    def auto_click_from_params
      @auto_click_from_params ||= params['auto_click'].presence
    end
  end
end
