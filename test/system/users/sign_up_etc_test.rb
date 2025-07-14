# frozen_string_literal: true

require "application_system_test_case"

class SignUpEtcTest < ApplicationSystemTestCase
  test "sign up, reset password, sign in, sign out, change email, change email reversion" do
    perform_enqueued_jobs do
      visit(root_path)

      click_on("Sign Up")

      assert_text("Sign Up: Email Confirmation")

      fill_in("Email address", with: "user@example.com")
      click_on("Send verification code")

      assert_text("Email address domain is not supported.")

      fill_in("Email address", with: "user@upper.town")
      click_on("Send verification code")

      assert_text("Verification code has been sent to your email.")

      code = match_code(find_mail_message("Email Confirmation: verification code"))

      fill_in("Code", with: "XXX")
      click_on("Confirm my email address")

      assert_text("Invalid or expired token or code.")

      fill_in("Code", with: " ")
      click_on("Confirm my email address")

      assert_text("Code can't be blank.")

      fill_in("Code", with: code)
      click_on("Confirm my email address")

      assert_text("Email address has been confirmed.")
      assert_text("Set a password for your account.")

      fill_in("Email address", with: "user@upper.town")
      click_on("Send verification code")

      assert_text("Verification code has been sent to your email.")
      assert_text("Set your password")

      code = match_code(find_mail_message("Password Reset: verification code"))

      fill_in("Verification Code", with: code)
      fill_in("New Password", with: " ")
      click_on("Set password")

      assert_text("New Password can't be blank.")
      assert_text("New Password is too short (minimum is 8 characters).")

      fill_in("Verification Code", with: "XXX")
      fill_in("New Password", with: "testpass")
      click_on("Set password")

      assert_text("Invalid or expired token or code.")

      fill_in("Verification Code", with: code)
      fill_in("New Password", with: "testpass")
      click_on("Set password")

      assert_text("Your password has been set.")
      assert_text("Sign In")

      fill_in("Email address", with: "user@example.com")
      fill_in("Password", with: " ")
      click_on("Submit")

      assert_text("Email address domain is not supported.")
      assert_text("Password can't be blank.")

      fill_in("Email address", with: "user@upper.town")
      fill_in("Password", with: "testpass")
      check("Remember me")
      click_on("Submit")

      assert_text("You are logged in.")

      session = Session.last
      assert(session.token_digest.present?)
      assert_equal("user@upper.town", session.user.email)
      assert_in_delta(4.months.from_now, session.expires_at, 10.minutes)

      click_on("Sign Out")

      assert_text("Your have been logged out.")

      assert_raises(ActiveRecord::RecordNotFound) do
        session.reload
      end

      click_on("Sign In")

      fill_in("Email address", with: "user@upper.town")
      fill_in("Password", with: "testpass")
      click_on("Submit")

      assert_text("You are logged in.")

      session = Session.last
      assert(session.token_digest.present?)
      assert_equal("user@upper.town", session.user.email)
      assert_in_delta(1.day.from_now, session.expires_at, 10.minutes)

      click_on("Manage my Account")

      assert_text("Manage your account")

      click_on("Change Email address")

      fill_in("Current Email", with: "xxx@xxx")
      fill_in("New Email", with: "yyy@yyy")
      fill_in("Current Password", with: "xxx")
      click_on("Change email")

      assert_text("Current Email format is invalid.")
      assert_text("New Email format is invalid.")

      fill_in("Current Email", with: "someone.else@upper.town")
      fill_in("New Email", with: "user.new@upper.town")
      fill_in("Current Password", with: "xxx")
      click_on("Change email")

      assert_text("Incorrect current email.")

      fill_in("Current Email", with: "user@upper.town")
      fill_in("New Email", with: "user.new@upper.town")
      fill_in("Current Password", with: "xxx")
      click_on("Change email")

      assert_text("Incorrect password or email.")

      fill_in("Current Email", with: "user@upper.town")
      fill_in("New Email", with: "user.new@upper.town")
      fill_in("Current Password", with: "testpass")
      click_on("Change email")

      assert_text("Verification code has been sent to your email.")
      assert_text("Change Email: confirmation")

      code = match_code(find_mail_message("Change Email: verification code"))

      fill_in("Code", with: "XXX")
      click_on("Confirm my New Email address")

      assert_text("Invalid or expired token or code")

      fill_in("Code", with: code)
      click_on("Confirm my New Email address")

      assert_text("Email address has been changed.")

      click_on("Sign Out")

      assert_text("Your have been logged out.")

      click_on("Sign In")

      fill_in("Email address", with: "user@upper.town")
      fill_in("Password", with: "testpass")
      click_on("Submit")

      assert_text("Incorrect password or email.")

      fill_in("Email address", with: "user.new@upper.town")
      fill_in("Password", with: "testpass")
      click_on("Submit")

      assert_text("You are logged in.")

      mail_message = find_mail_message("Change Email: reversion link")
      link = match_link(mail_message, "Change email reversion link")
      code = match_code(mail_message)

      visit(link)

      assert_text("Change email: reversion")

      fill_in("Verification Code", with: "XXX")
      click_on("Confirm and restore my email address")

      assert_text("Invalid or expired token or code.")

      fill_in("Verification Code", with: code)
      click_on("Confirm and restore my email address")

      assert_text("Email address has been restored.")

      click_on("Sign Out")

      assert_text("Your have been logged out.")

      click_on("Sign In")

      fill_in("Email address", with: "user.new@upper.town")
      fill_in("Password", with: "testpass")
      click_on("Submit")

      assert_text("Incorrect password or email.")

      fill_in("Email address", with: "user@upper.town")
      fill_in("Password", with: "testpass")
      click_on("Submit")

      assert_text("You are logged in.")
    end
  end

  def find_mail_message(subject)
    ActionMailer::Base.deliveries.find do |mail_message|
      mail_message.subject.include?(subject)
    end || raise("find_mail_message: not found")
  end

  def match_code(mail_message)
    /(\b[ABCDEFGHJKLMNPQRSTUWXYZ123456789]{8}\b)/
      .match(mail_message.body.to_s)[1]
      .presence || raise("match_code: not matched")
  end

  def match_link(mail_message, text)
    /<a href="(.+)">#{text}<\/a>/
      .match(mail_message.body.to_s)[1]
      .presence || raise("match_link: not matched")
  end
end
