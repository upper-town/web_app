# frozen_string_literal: true

class UsersMailer < ApplicationMailer
  def email_confirmation
    @email = params[:email]
    @email_confirmation_code = params[:email_confirmation_code]

    mail(
      to: @email,
      subject: "Email Confirmation: verification code"
    )
  end

  def password_reset
    @email = params[:email]
    @password_reset_code = params[:password_reset_code]

    mail(
      to: @email,
      subject: "Password Reset: verification code"
    )
  end

  def change_email_reversion
    @email = params[:email]
    @change_email = params[:change_email]
    @change_email_reversion_token = params[:change_email_reversion_token]

    mail(
      to: @email,
      subject: "Change Email: reversion link"
    )
  end

  def change_email_confirmation
    @email = params[:email]
    @change_email = params[:change_email]
    @change_email_confirmation_code = params[:change_email_confirmation_code]

    mail(
      to: @change_email,
      subject: "Change Email: verification code"
    )
  end
end
