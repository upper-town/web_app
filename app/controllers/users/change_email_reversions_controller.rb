# frozen_string_literal: true

module Users
  class ChangeEmailReversionsController < ApplicationController
    before_action :set_change_email_reversion, only: [:edit, :update]

    rate_limit(
      to: 6,
      within: 1.minute,
      with: -> { render_rate_limited(:edit) },
      name: "update",
      only: [:update]
    )

    def edit
    end

    def update
      if @change_email_reversion.invalid?
        flash.now[:alert] = @change_email_reversion.errors
        render(:edit, status: :unprocessable_entity)

        return
      end

      result = ChangeEmailReversions::Update.call(
        @change_email_reversion.token,
        @change_email_reversion.code
      )

      if result.success?
        flash[:success] = t("users.change_email_reversions.email_restored")
        redirect_to(signed_in_user? ? inside_dashboard_path : root_path)
      else
        flash.now[:alert] = result.errors
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def set_change_email_reversion
      @change_email_reversion = ChangeEmailReversion.new(permitted_params[:users_change_email_reversion])

      if @change_email_reversion.token.blank?
        @change_email_reversion.token = permitted_params[:token].presence
      end
    end

    def permitted_params
      params.permit(
        :token,
        users_change_email_reversion: [:token, :code]
      )
    end
  end
end
