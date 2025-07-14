# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def email_confirmation(email, email_confirmation_code)
    @email = email
    @email_confirmation_code = email_confirmation_code

    mail(
      to: @email,
      subject: t("users_mailer.email_confirmation.subject")
    )
  end

  def password_reset(email, password_reset_code)
    @email = email
    @password_reset_code = password_reset_code

    mail(
      to: @email,
      subject: t("users_mailer.password_reset.subject")
    )
  end

  def change_email_reversion(email, change_email, change_email_reversion_token, change_email_reversion_code)
    @email = email
    @change_email = change_email
    @change_email_reversion_token = change_email_reversion_token
    @change_email_reversion_code = change_email_reversion_code

    mail(
      to: @email,
      subject: t("users_mailer.change_email_reversion.subject")
    )
  end

  def change_email_confirmation(email, change_email, change_email_confirmation_code)
    @email = email
    @change_email = change_email
    @change_email_confirmation_code = change_email_confirmation_code

    mail(
      to: @change_email,
      subject: t("users_mailer.change_email.subject")
    )
  end
end
