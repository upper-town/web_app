# frozen_string_literal: true

class UsersMailer < ApplicationMailer
  def email_confirmation
    @email = params[:email]
    @email_confirmation_token = params[:email_confirmation_token]

    mail(
      to: @email,
      subject: 'Upper Town: Email confirmation link'
    )
  end

  def change_email_reversion
    @email = params[:email]
    @change_email = params[:change_email]
    @change_email_reversion_token = params[:change_email_reversion_token]

    mail(
      to: @email,
      subject: 'Upper Town: Change email reversion link'
    )
  end

  def change_email_confirmation
    @email = params[:email]
    @change_email = params[:change_email]
    @change_email_confirmation_token = params[:change_email_confirmation_token]

    mail(
      to: @change_email,
      subject: 'Upper Town: Change email confirmation link'
    )
  end

  def password_reset
    @email = params[:email]
    @password_reset_token = params[:password_reset_token]

    mail(
      to: @email,
      subject: 'Upper Town: Password Reset Email'
    )
  end
end
