# frozen_string_literal: true

require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "email_confirmation" do
    email = UserMailer.email_confirmation(
      "user@upper.town",
      "ABCD1234"
    )

    assert_emails(1) do
      email.deliver_now
    end

    assert_equal([ENV.fetch("NOREPLY_EMAIL")], email.from)
    assert_equal(["user@upper.town"], email.to)
    assert_equal("Email Confirmation: verification code", email.subject)
    assert_includes(email.body, "ABCD1234")
  end

  test "password_reset" do
    email = UserMailer.password_reset(
      "user@upper.town",
      "ABCD1234"
    )

    assert_emails(1) do
      email.deliver_now
    end

    assert_equal([ENV.fetch("NOREPLY_EMAIL")], email.from)
    assert_equal(["user@upper.town"], email.to)
    assert_equal("Password Reset: verification code", email.subject)
    assert_includes(email.body, "ABCD1234")
  end

  test "change_email_reversion" do
    email = UserMailer.change_email_reversion(
      "user@upper.town",
      "user.new@upper.town",
      "abcdef123456",
      "ABCD1234"
    )

    assert_emails(1) do
      email.deliver_now
    end

    assert_equal([ENV.fetch("NOREPLY_EMAIL")], email.from)
    assert_equal(["user@upper.town"], email.to)
    assert_equal("Change Email: reversion link", email.subject)
    assert_includes(email.body, "user@upper.town")
    assert_includes(email.body, "user.new@upper.town")
    assert_includes(email.body, edit_users_change_email_reversion_url(token: "abcdef123456"))
    assert_includes(email.body, "ABCD1234")
  end

  test "change_email_confirmation" do
    email = UserMailer.change_email_confirmation(
      "user@upper.town",
      "user.new@upper.town",
      "ABCD1234"
    )

    assert_emails(1) do
      email.deliver_now
    end

    assert_equal([ENV.fetch("NOREPLY_EMAIL")], email.from)
    assert_equal(["user.new@upper.town"], email.to)
    assert_equal("Change Email: verification code", email.subject)
    assert_includes(email.body, "user@upper.town")
    assert_includes(email.body, "user.new@upper.town")
    assert_includes(email.body, "ABCD1234")
  end
end
