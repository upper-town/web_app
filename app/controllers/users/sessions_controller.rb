# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    before_action :authenticate_user!, only: [:destroy, :destroy_all]

    def new
      if signed_in?
        redirect_to(
          inside_dashboard_path,
          notice: 'You are logged in already.'
        )
        return
      end

      @new_form = Users::Sessions::NewForm.new
    end

    def create
      if signed_in?
        redirect_to(
          inside_dashboard_path,
          notice: 'You are logged in already.'
        )
        return
      end

      @new_form = Users::Sessions::NewForm.new(new_form_params)

      result = captcha_check(if_success_skip_paths: [users_sign_in_path, users_sessions_path])

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

      result = Users::AuthenticateSession.new(@new_form.attributes, request).call

      if result.success?
        sign_in!(result.data[:user], @new_form.remember_me)
        return_to = consume_return_to

        redirect_to(
          return_to || inside_dashboard_path,
          success: 'You are logged in.'
        )
      else
        flash.now[:info] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def destroy
      sign_out!

      redirect_to(
        root_path,
        info: 'Your have been logged out.'
      )
    end

    def destroy_all
      # TODO: implement
    end

    private

    def new_form_params
      params
        .require('users_sessions_new_form')
        .permit(
          'email',
          'password',
          'remember_me'
        )
    end
  end
end
