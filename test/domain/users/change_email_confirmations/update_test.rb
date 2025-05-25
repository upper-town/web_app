# frozen_string_literal: true

require "test_helper"

class Users::ChangeEmailConfirmations::UpdateTest < ActiveSupport::TestCase
  let(:described_class) { Users::ChangeEmailConfirmations::Update }

  describe "#call" do
    describe "when user is not found by token" do
      describe "non-existing token" do
        it "returns failure" do
          user = create_user(email: "user@upper.town", change_email: "user.change@upper.town")
          _token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: "user.change@upper.town" })
          change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: "xxxxxxxx")

          result = described_class.new(change_email_confirmation_edit).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
        end
      end

      describe "expired token" do
        it "returns failure" do
          user = create_user(email: "user@upper.town", change_email: "user.change@upper.town")
          token = user.generate_token!(:change_email_confirmation, 0.seconds, { change_email: "user.change@upper.town" })
          change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)

          result = described_class.new(change_email_confirmation_edit).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/Invalid or expired token/) })
        end
      end
    end

    describe "when user is found by token" do
      describe "when change_email has already been confirmed" do
        it "returns failure" do
          user = create_user(
            email: "user@upper.town",
            change_email: "user.change@upper.town",
            change_email_confirmed_at: Time.current
          )
          token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: "user.change@upper.town" })
          change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)

          result = described_class.new(change_email_confirmation_edit).call

          assert(result.failure?)
          assert(result.errors[:base].any? { it.match?(/New Email address has already been confirmed/) })
        end
      end

      describe "when token data does not have the expected change_email" do
        it "returns failure" do
          [
            ["user1@upper.town", "user.change1@upper.town", " "],
            ["user2@upper.town", "user.change2@upper.town", "something.else@upper.town"],
            ["user3@upper.town", " ",                       "user.change3@upper.town"]
          ].each do |email, change_email, token_data_change_email|
            user = create_user(email: email, change_email: change_email)
            token = user.generate_token!(
              :change_email_confirmation,
              1.hour,
              { change_email: token_data_change_email }
            )
            change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)

            result = described_class.new(change_email_confirmation_edit).call

            assert(result.failure?)
            assert(result.errors[:base].any? { it.match?(/Invalid token: new email address is not associated with token/) })
          end
        end
      end

      describe "when trying to confirm change_email raises an error" do
        it "raises an error" do
          user = create_user(email: "user@upper.town", change_email: "user.change@upper.town")
          token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: "user.change@upper.town" })
          change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)

          called = 0
          User.stub_any_instance(:update!, ->(*) { called += 1 ; raise ActiveRecord::ActiveRecordError }) do
            assert_raises(ActiveRecord::ActiveRecordError) do
              described_class.new(change_email_confirmation_edit).call
            end
          end
          assert_equal(1, called)
        end
      end

      describe "when trying to confirm change_email succeeds" do
        it "returns success and expires tokens" do
          freeze_time do
            user = create_user(email: "user@upper.town", change_email: "user.change@upper.town")
            token = user.generate_token!(:change_email_confirmation, 1.hour, { change_email: "user.change@upper.town" })
            change_email_confirmation_edit = Users::ChangeEmailConfirmationEdit.new(token: token)

            result = described_class.new(change_email_confirmation_edit).call

            assert(result.success?)
            assert_equal("user.change@upper.town", result.user.email)
            assert(result.user.change_email.blank?)
            assert_equal(Time.current, result.user.change_email_confirmed_at)
            assert_equal(Time.current, result.user.email_confirmed_at)
            assert_nil(User.find_by_token(:change_email_confirmation, token))
          end
        end
      end
    end
  end
end
