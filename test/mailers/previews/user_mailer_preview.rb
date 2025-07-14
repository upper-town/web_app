# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def email_confirmation
    UserMailer.email_confirmation(
      "user@upper.town",
      "ABCD1234"
    )
  end

  def password_reset
    UserMailer.password_reset(
      "user@upper.town",
      "ABCD1234"
    )
  end

  def change_email_reversion
    UserMailer.change_email_reversion(
      "user@upper.town",
      "user.new@upper.town",
      "abcdef123456",
      "ABCD1234"
    )
  end

  def change_email_confirmation
    UserMailer.change_email_confirmation(
      "user@upper.town",
      "user.new@upper.town",
      "ABCD1234"
    )
  end
end
