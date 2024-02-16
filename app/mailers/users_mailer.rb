# frozen_string_literal: true

class UsersMailer < ApplicationMailer
  def confirmation
    @email = params[:email]
    @confirmation_token = params[:confirmation_token]

    mail(
      to: @email,
      subject: 'Upper Town: Email confirmation link'
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
