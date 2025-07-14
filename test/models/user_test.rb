# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  let(:described_class) { User }

  describe "associations" do
    it "has many sessions" do
      user = create_user
      session1 = create_session(user:)
      session2 = create_session(user:)

      assert_equal(
        [session1, session2].sort,
        user.sessions.sort
      )
      user.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { session1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { session2.reload }
    end

    it "has many tokens" do
      user = create_user
      token1 = create_token(user:)
      token2 = create_token(user:)

      assert_equal(
        [token1, token2].sort,
        user.tokens.sort
      )
      user.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { token1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { token2.reload }
    end

    it "has one account" do
      user = create_user
      account = create_account(user:)

      assert_equal(account, user.account)
      user.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { account.reload }
    end
  end

  describe "FeatureFlagId" do
    describe "#to_ffid" do
      it "returns the class name, underscore, record id" do
        user = create_user

        assert_equal("user_#{user.id}", user.to_ffid)
      end
    end
  end

  describe "HasTokens" do
    describe ".find_by_token" do
      describe "when purpose is blank" do
        it "returns nil" do
          user = described_class.find_by_token("", "abcdef123456")

          assert_nil(user)
        end
      end

      describe "when token is blank" do
        it "returns nil" do
          user = described_class.find_by_token(:email_confirmation, "")

          assert_nil(user)
        end
      end

      describe "when token is not found" do
        it "returns nil" do
          user = described_class.find_by_token(:email_confirmation, "abcdef123456")

          assert_nil(user)
        end
      end

      describe "when token is found but expired" do
        it "returns nil" do
          freeze_time do
            token = create_token(
              token_digest: TokenGenerator.digest("abcdef123456"),
              expires_at: 1.second.ago
            )

            user = described_class.find_by_token(token.purpose, "abcdef123456")

            assert_nil(user)
          end
        end
      end

      describe "when token is found and not expired" do
        it "returns user" do
          freeze_time do
            token = create_token(
              token_digest: TokenGenerator.digest("abcdef123456"),
              expires_at: 1.second.from_now
            )

            user = described_class.find_by_token(token.purpose, "abcdef123456")

            assert_equal(token.user, user)
          end
        end
      end
    end

    describe "#generate_token!" do
      it "creates a Token record and returns token" do
        freeze_time do
          user = create_user
          returned_token = nil

          assert_difference(-> { Token.count }, 1) do
            returned_token = user.generate_token!(:email_confirmation, 15.minutes, { "some" => "data" })
          end

          token = Token.last
          assert_equal("email_confirmation", token.purpose)
          assert_equal(TokenGenerator.digest(returned_token), token.token_digest)
          assert_equal(returned_token.last(4), token.token_last_four)
          assert_equal(15.minutes.from_now, token.expires_at)
          assert_equal({ "some" => "data" }, token.data)
        end
      end

      describe "default expires_in and data" do
        it "creates a Token record and returns token" do
          freeze_time do
            user = create_user
            returned_token = nil

            assert_difference(-> { Token.count }, 1) do
              returned_token = user.generate_token!(:email_confirmation)
            end

            token = Token.last
            assert_equal("email_confirmation", token.purpose)
            assert_equal(TokenGenerator.digest(returned_token), token.token_digest)
            assert_equal(returned_token.last(4), token.token_last_four)
            assert_equal(1.hour.from_now, token.expires_at)
            assert_equal({}, token.data)
          end
        end
      end
    end

    describe "#expire_token!" do
      describe "when purpose is blank" do
        it "does not expire user tokens" do
          freeze_time do
            user = create_user
            token1 = create_token(
              user:,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )
            token2 = create_token(
              user:,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )
            token3 = create_token(
              user:,
              purpose: "something_else",
              expires_at: 2.days.from_now
            )
            another_user = create_user
            token4 = create_token(
              user: another_user,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )

            user.expire_token!(" ")

            assert_equal(2.days.from_now, token1.reload.expires_at)
            assert_equal(2.days.from_now, token2.reload.expires_at)
            assert_equal(2.days.from_now, token3.reload.expires_at)
            assert_equal(2.days.from_now, token4.reload.expires_at)
          end
        end
      end

      describe "when purpose is present" do
        it "expires user tokens with that purpose" do
          freeze_time do
            user = create_user
            token1 = create_token(
              user:,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )
            token2 = create_token(
              user:,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )
            token3 = create_token(
              user:,
              purpose: "something_else",
              expires_at: 2.days.from_now
            )
            another_user = create_user
            token4 = create_token(
              user: another_user,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )

            user.expire_token!(:email_confirmation)

            assert_equal(2.days.ago, token1.reload.expires_at)
            assert_equal(2.days.ago, token2.reload.expires_at)
            assert_equal(2.days.from_now, token3.reload.expires_at)
            assert_equal(2.days.from_now, token4.reload.expires_at)
          end
        end
      end
    end
  end

  describe "HasCodes" do
    describe ".find_by_code" do
      describe "when purpose is blank" do
        it "returns nil" do
          user = described_class.find_by_code("", "ABCD1234")

          assert_nil(user)
        end
      end

      describe "when code is blank" do
        it "returns nil" do
          user = described_class.find_by_code(:email_confirmation, "")

          assert_nil(user)
        end
      end

      describe "when code is not found" do
        it "returns nil" do
          user = described_class.find_by_code(:email_confirmation, "ABCD1234")

          assert_nil(user)
        end
      end

      describe "when code is found but expired" do
        it "returns nil" do
          freeze_time do
            code = create_code(
              code_digest: CodeGenerator.digest("ABCD1234"),
              expires_at: 1.second.ago
            )

            user = described_class.find_by_code(code.purpose, "ABCD1234")

            assert_nil(user)
          end
        end
      end

      describe "when code is found and not expired" do
        it "returns user" do
          freeze_time do
            code = create_code(
              code_digest: CodeGenerator.digest("ABCD1234"),
              expires_at: 1.second.from_now
            )

            user = described_class.find_by_code(code.purpose, "ABCD1234")

            assert_equal(code.user, user)
          end
        end
      end
    end

    describe "#generate_code!" do
      it "creates a Code record and returns code" do
        freeze_time do
          user = create_user
          returned_code = nil

          assert_difference(-> { Code.count }, 1) do
            returned_code = user.generate_code!(:email_confirmation, 15.minutes, { "some" => "data" })
          end

          code = Code.last
          assert_equal("email_confirmation", code.purpose)
          assert_equal(CodeGenerator.digest(returned_code), code.code_digest)
          assert_equal(15.minutes.from_now, code.expires_at)
          assert_equal({ "some" => "data" }, code.data)
        end
      end

      describe "default expires_in and data" do
        it "creates a Code record and returns code" do
          freeze_time do
            user = create_user
            returned_code = nil

            assert_difference(-> { Code.count }, 1) do
              returned_code = user.generate_code!(:email_confirmation)
            end

            code = Code.last
            assert_equal("email_confirmation", code.purpose)
            assert_equal(CodeGenerator.digest(returned_code), code.code_digest)
            assert_equal(30.minutes.from_now, code.expires_at)
            assert_equal({}, code.data)
          end
        end
      end
    end

    describe "#expire_code!" do
      describe "when purpose is blank" do
        it "does not expire user codes" do
          freeze_time do
            user = create_user
            code1 = create_code(
              user:,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )
            code2 = create_code(
              user:,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )
            code3 = create_code(
              user:,
              purpose: "something_else",
              expires_at: 2.days.from_now
            )
            another_user = create_user
            code4 = create_code(
              user: another_user,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )

            user.expire_code!(" ")

            assert_equal(2.days.from_now, code1.reload.expires_at)
            assert_equal(2.days.from_now, code2.reload.expires_at)
            assert_equal(2.days.from_now, code3.reload.expires_at)
            assert_equal(2.days.from_now, code4.reload.expires_at)
          end
        end
      end

      describe "when purpose is present" do
        it "expires user codes with that purpose" do
          freeze_time do
            user = create_user
            code1 = create_code(
              user:,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )
            code2 = create_code(
              user:,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )
            code3 = create_code(
              user:,
              purpose: "something_else",
              expires_at: 2.days.from_now
            )
            another_user = create_user
            code4 = create_code(
              user: another_user,
              purpose: :email_confirmation,
              expires_at: 2.days.from_now
            )

            user.expire_code!(:email_confirmation)

            assert_equal(2.days.ago, code1.reload.expires_at)
            assert_equal(2.days.ago, code2.reload.expires_at)
            assert_equal(2.days.from_now, code3.reload.expires_at)
            assert_equal(2.days.from_now, code4.reload.expires_at)
          end
        end
      end
    end
  end

  describe "HasEmailConfirmation" do
    describe "normalizations" do
      it "normalizes email" do
        user = build_user(email: nil)
        assert_nil(user.email)

        user = build_user(email: "\n\t USER  @UPPER .Town \n")
        assert_equal("user@upper.town", user.email)
      end
    end

    describe "validations" do
      it "validates email" do
        user = build_user(email: "")
        user.validate
        assert(user.errors.of_kind?(:email, :blank))

        user = build_user(email: "@upper.town")
        user.validate
        assert(user.errors.of_kind?(:email, :format_invalid))

        user = build_user(email: "user@example.com")
        user.validate
        assert(user.errors.of_kind?(:email, :domain_not_supported))
      end
    end

    describe "#confirmed_email?" do
      describe "when email_confirmed_at is blank" do
        it "returns false" do
          user = create_user(email_confirmed_at: nil)

          assert_not(user.confirmed_email?)
        end
      end

      describe "when email_confirmed_at is present" do
        it "returns true" do
          user = create_user(email_confirmed_at: Time.current)

          assert(user.confirmed_email?)
        end
      end
    end

    describe "#unconfirmed_email?" do
      describe "when email_confirmed_at is blank" do
        it "returns true" do
          user = create_user(email_confirmed_at: nil)

          assert(user.unconfirmed_email?)
        end
      end

      describe "when email_confirmed_at is present" do
        it "returns false" do
          user = create_user(email_confirmed_at: Time.current)

          assert_not(user.unconfirmed_email?)
        end
      end
    end

    describe "#confirm_email!" do
      it "updates email_confirmed_at to the current time" do
        freeze_time do
          user = create_user(email_confirmed_at: nil)

          user.confirm_email!

          assert_equal(Time.current, user.email_confirmed_at)
        end
      end
    end

    describe "#unconfirm_email!" do
      it "updates email_confirmed_at to nil" do
        user = create_user(email_confirmed_at: Time.current)

        user.unconfirm_email!

        assert_nil(user.email_confirmed_at)
      end
    end
  end

  describe "HasChangeEmailConfirmation" do
    describe "normalizations" do
      it "normalizes change_email" do
        user = build_user(change_email: nil)
        assert_nil(user.change_email)

        user = build_user(change_email: "\n\t USER  @UPPER .Town \n")
        assert_equal("user@upper.town", user.change_email)
      end
    end

    describe "validations" do
      it "validates change_email" do
        user = build_user(change_email: nil)
        user.validate
        assert_not(user.errors.key?(:change_email))

        user = build_user(change_email: "")
        user.validate
        assert(user.errors.of_kind?(:change_email, :too_short))

        user = build_user(change_email: "@upper.town")
        user.validate
        assert(user.errors.of_kind?(:change_email, :format_invalid))

        user = build_user(change_email: "user@example.com")
        user.validate
        assert(user.errors.of_kind?(:change_email, :domain_not_supported))
      end
    end

    describe "#confirmed_change_email?" do
      describe "when change_email_confirmed_at is blank" do
        it "returns false" do
          user = create_user(change_email_confirmed_at: nil)

          assert_not(user.confirmed_change_email?)
        end
      end

      describe "when change_email_confirmed_at is present" do
        it "returns true" do
          user = create_user(change_email_confirmed_at: Time.current)

          assert(user.confirmed_change_email?)
        end
      end
    end

    describe "#unconfirmed_change_email?" do
      describe "when change_email_confirmed_at is blank" do
        it "returns true" do
          user = create_user(change_email_confirmed_at: nil)

          assert(user.unconfirmed_change_email?)
        end
      end

      describe "when change_email_confirmed_at is present" do
        it "returns false" do
          user = create_user(change_email_confirmed_at: Time.current)

          assert_not(user.unconfirmed_change_email?)
        end
      end
    end

    describe "#confirm_change_email!" do
      it "updates change_email_confirmed_at to the current time" do
        freeze_time do
          user = create_user(change_email_confirmed_at: nil)

          user.confirm_change_email!

          assert_equal(Time.current, user.change_email_confirmed_at)
        end
      end
    end

    describe "#unconfirm_change_email!" do
      it "updates change_email_confirmed_at to nil" do
        user = create_user(change_email_confirmed_at: Time.current)

        user.unconfirm_change_email!

        assert_nil(user.change_email_confirmed_at)
      end
    end

    describe "#revert_change_email!" do
      it "reverts email to the previous_email" do
        freeze_time do
          user = create_user(
            email: "user@upper.town",
            email_confirmed_at: 2.hours.ago,
            change_email: "user@upper.town",
            change_email_confirmed_at: 1.hour.ago,
            change_email_reverted_at: nil
          )

          user.revert_change_email!("previous.user@upper.town")

          assert_equal("previous.user@upper.town", user.email)
          assert_equal(Time.current, user.email_confirmed_at)
          assert_nil(user.change_email)
          assert_nil(user.change_email_confirmed_at)
          assert_equal(Time.current, user.change_email_reverted_at)
        end
      end
    end
  end

  describe "HasLock" do
    describe "#locked?" do
      describe "when locked_at is blank" do
        it "returns false" do
          user = create_user(locked_at: nil)

          assert_not(user.locked?)
        end
      end

      describe "when locked_at is present" do
        it "returns true" do
          user = create_user(locked_at: Time.current)

          assert(user.locked?)
        end
      end
    end

    describe "#unlocked?" do
      describe "when locked_at is blank" do
        it "returns true" do
          user = create_user(locked_at: nil)

          assert(user.unlocked?)
        end
      end

      describe "when locked_at is present" do
        it "returns false" do
          user = create_user(locked_at: Time.current)

          assert_not(user.unlocked?)
        end
      end
    end

    describe "#lock_access!" do
      it "updates locked attributes" do
        freeze_time do
          user = create_user(locked_reason: nil, locked_comment: nil, locked_at: nil)

          user.lock_access!("Bad Actor", "User did bad things")

          assert_equal("Bad Actor", user.locked_reason)
          assert_equal("User did bad things", user.locked_comment)
          assert_equal(Time.current, user.locked_at)
        end
      end
    end

    describe "#unlock_access!" do
      it "set locked attributes to nil" do
        user = create_user(
          locked_reason: "Bad Actor",
          locked_comment: "User did bad things",
          locked_at: Time.current
        )

        user.unlock_access!

        assert_nil(user.locked_reason)
        assert_nil(user.locked_comment)
        assert_nil(user.locked_at)
      end
    end
  end

  describe "HasPassword" do
    it "has secure password" do
      user = build_user(email: "user@upper.town", password: "abcd1234")

      assert(user.password_digest.present?)
      assert_not_equal("abcd1234", user.password_digest)

      user.save!

      assert_equal(
        user,
        described_class.authenticate_by(email: "user@upper.town", password: "abcd1234")
      )
    end

    describe "#reset_password!" do
      it "updates password and password_reset_at" do
        freeze_time do
          user = create_user(password_digest: nil)

          user.reset_password!("abcd1234")

          assert(user.password_digest.present?)
          assert_not_equal("abcd1234", user.password_digest)
          assert_equal(Time.current, user.password_reset_at)

          assert_equal(
            user,
            described_class.authenticate_by(email: user.email, password: "abcd1234")
          )
        end
      end
    end

    describe "#clear_password!" do
      it "sets password and password_reset_at to nil" do
        freeze_time do
          user = create_user
          user.reset_password!("testpass")

          user.clear_password!

          assert_nil(user.password_digest)
          assert_nil(user.password_reset_at)

          assert_nil(
            described_class.authenticate_by(email: user.email, password: "testpass")
          )
        end
      end
    end
  end
end
