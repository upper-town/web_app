# frozen_string_literal: true

require "test_helper"

class AdminUserMailerTest < ActionMailer::TestCase
  test "email_confirmation" do
    email = AdminUserMailer.email_confirmation(
      "admin_user@upper.town",
      "abcdef123456",
      "ABCD1234"
    )

    assert_emails(1) do
      email.deliver_now
    end

    assert_equal([ENV.fetch("NOREPLY_EMAIL")], email.from)
    assert_equal(["admin_user@upper.town"], email.to)
    assert_equal("Email Confirmation: verification code", email.subject)
    assert_includes(email.body, edit_admin_users_email_confirmation_url(token: "abcdef123456"))
    assert_includes(email.body, "ABCD1234")
  end

  test "password_reset" do
    email = AdminUserMailer.password_reset(
      "admin_user@upper.town",
      "ABCD1234"
    )

    assert_emails(1) do
      email.deliver_now
    end

    assert_equal([ENV.fetch("NOREPLY_EMAIL")], email.from)
    assert_equal(["admin_user@upper.town"], email.to)
    assert_equal("Password Reset: verification code", email.subject)
    assert_includes(email.body, "ABCD1234")
  end
end
