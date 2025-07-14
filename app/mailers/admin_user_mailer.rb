# frozen_string_literal: true

class AdminUserMailer < ApplicationMailer
  def email_confirmation(email, email_confirmation_token, email_confirmation_code)
    @email = email
    @email_confirmation_token = email_confirmation_token
    @email_confirmation_code = email_confirmation_code

    mail(
      to: @email,
      subject: t("admin_users_mailer.email_confirmation.subject")
    )
  end

  def password_reset(email, password_reset_code)
    @email = email
    @password_reset_code = password_reset_code

    mail(
      to: @email,
      subject: t("admin_users_mailer.password_reset.subject")
    )
  end
end
