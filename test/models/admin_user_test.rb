# frozen_string_literal: true

require "test_helper"

class AdminUserTest < ActiveSupport::TestCase
  let(:described_class) { AdminUser }

  describe "associations" do
    it "has many sessions" do
      admin_user = create_admin_user
      admin_session1 = create_admin_session(admin_user:)
      admin_session2 = create_admin_session(admin_user:)

      assert_equal(
        [admin_session1, admin_session2].sort,
        admin_user.sessions.sort
      )
      admin_user.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { admin_session1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { admin_session2.reload }
    end

    it "has many tokens" do
      admin_user = create_admin_user
      admin_token1 = create_admin_token(admin_user:)
      admin_token2 = create_admin_token(admin_user:)

      assert_equal(
        [admin_token1, admin_token2].sort,
        admin_user.tokens.sort
      )
      admin_user.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { admin_token1.reload }
      assert_raises(ActiveRecord::RecordNotFound) { admin_token2.reload }
    end

    it "has one account" do
      admin_user = create_admin_user
      admin_account = create_admin_account(admin_user:)

      assert_equal(admin_account, admin_user.account)
      admin_user.destroy!
      assert_raises(ActiveRecord::RecordNotFound) { admin_account.reload }
    end
  end

  describe "FeatureFlagId" do
    describe "#to_ffid" do
      it "returns the class name, underscore, record id" do
        admin_user = create_admin_user

        assert_equal("admin_user_#{admin_user.id}", admin_user.to_ffid)
      end
    end
  end

  describe "HasAdminTokens" do
    describe ".find_by_token" do
      describe "when purpose is blank" do
        it "returns nil" do
          admin_user = described_class.find_by_token("", "abcdef123456")

          assert_nil(admin_user)
        end
      end

      describe "when token is blank" do
        it "returns nil" do
          admin_user = described_class.find_by_token("email_confirmation", "")

          assert_nil(admin_user)
        end
      end

      describe "when token is not found" do
        it "returns nil" do
          admin_user = described_class.find_by_token("email_confirmation", "abcdef123456")

          assert_nil(admin_user)
        end
      end

      describe "when token is found but expired" do
        it "returns nil" do
          freeze_time do
            admin_token = create_admin_token(
              token_digest: TokenGenerator::Admin.digest("abcdef123456"),
              expires_at: 1.second.ago
            )

            admin_user = described_class.find_by_token(admin_token.purpose, "abcd1234")

            assert_nil(admin_user)
          end
        end
      end

      describe "when token is found and not expired" do
        it "returns admin_user" do
          freeze_time do
            admin_token = create_admin_token(
              token_digest: TokenGenerator::Admin.digest("abcdef123456"),
              expires_at: 1.second.from_now
            )

            admin_user = described_class.find_by_token(admin_token.purpose, "abcdef123456")

            assert_equal(admin_token.admin_user, admin_user)
          end
        end
      end
    end

    describe "#generate_token!" do
      it "creates an AdminToken record and returns token" do
        freeze_time do
          admin_user = create_admin_user
          returned_token = nil

          assert_difference(-> { AdminToken.count }, 1) do
            returned_token = admin_user.generate_token!("email_confirmation", 15.minutes, { "some" => "data" })
          end

          admin_token = AdminToken.last
          assert_equal("email_confirmation", admin_token.purpose)
          assert_equal(TokenGenerator::Admin.digest(returned_token), admin_token.token_digest)
          assert_equal(returned_token.last(4), admin_token.token_last_four)
          assert_equal(15.minutes.from_now, admin_token.expires_at)
          assert_equal({ "some" => "data" }, admin_token.data)
        end
      end

      describe "default expires_in and data" do
        it "creates a AdminToken record and returns token" do
          freeze_time do
            admin_user = create_admin_user
            returned_token = nil

            assert_difference(-> { AdminToken.count }, 1) do
              returned_token = admin_user.generate_token!("email_confirmation")
            end

            admin_token = AdminToken.last
            assert_equal("email_confirmation", admin_token.purpose)
            assert_equal(TokenGenerator::Admin.digest(returned_token), admin_token.token_digest)
            assert_equal(returned_token.last(4), admin_token.token_last_four)
            assert_equal(1.hour.from_now, admin_token.expires_at)
            assert_equal({}, admin_token.data)
          end
        end
      end
    end

    describe "#expire_token!" do
      describe "when purpose is blank" do
        it "does not expire admin_user tokens" do
          freeze_time do
            admin_user = create_admin_user
            admin_token1 = create_admin_token(
              admin_user:,
              purpose: "email_confirmation",
              expires_at: 2.days.from_now
            )
            admin_token2 = create_admin_token(
              admin_user:,
              purpose: "email_confirmation",
              expires_at: 2.days.from_now
            )
            admin_token3 = create_admin_token(
              admin_user:,
              purpose: "something_else",
              expires_at: 2.days.from_now
            )
            another_admin_user = create_admin_user
            admin_token4 = create_admin_token(
              admin_user: another_admin_user,
              purpose: "email_confirmation",
              expires_at: 2.days.from_now
            )

            admin_user.expire_token!(" ")

            assert_equal(2.days.from_now, admin_token1.reload.expires_at)
            assert_equal(2.days.from_now, admin_token2.reload.expires_at)
            assert_equal(2.days.from_now, admin_token3.reload.expires_at)
            assert_equal(2.days.from_now, admin_token4.reload.expires_at)
          end
        end
      end

      describe "when purpose is present" do
        it "expires admin_user tokens with that purpose" do
          freeze_time do
            admin_user = create_admin_user
            admin_token1 = create_admin_token(
              admin_user:,
              purpose: "email_confirmation",
              expires_at: 2.days.from_now
            )
            admin_token2 = create_admin_token(
              admin_user:,
              purpose: "email_confirmation",
              expires_at: 2.days.from_now
            )
            admin_token3 = create_admin_token(
              admin_user:,
              purpose: "something_else",
              expires_at: 2.days.from_now
            )
            another_admin_user = create_admin_user
            admin_token4 = create_admin_token(
              admin_user: another_admin_user,
              purpose: "email_confirmation",
              expires_at: 2.days.from_now
            )

            admin_user.expire_token!("email_confirmation")

            assert_equal(2.days.ago, admin_token1.reload.expires_at)
            assert_equal(2.days.ago, admin_token2.reload.expires_at)
            assert_equal(2.days.from_now, admin_token3.reload.expires_at)
            assert_equal(2.days.from_now, admin_token4.reload.expires_at)
          end
        end
      end
    end
  end

  describe "HasEmailConfirmation" do
    describe "normalizations" do
      it "normalizes email" do
        admin_user = build_admin_user(email: nil)
        assert_nil(admin_user.email)

        admin_user = build_admin_user(email: "\n\t Admin_USER  @UPPER .Town \n")
        assert_equal("admin_user@upper.town", admin_user.email)
      end
    end

    describe "validations" do
      it "validates email" do
        admin_user = build_admin_user(email: "")
        admin_user.validate
        assert(admin_user.errors.of_kind?(:email, :blank))

        admin_user = build_admin_user(email: "xxx@xxx")
        admin_user.validate
        assert(admin_user.errors.of_kind?(:email, :format_invalid))

        admin_user = build_user(email: "admin_user@example.com")
        admin_user.validate
        assert(admin_user.errors.of_kind?(:email, :domain_not_supported))
      end
    end

    describe "#confirmed_email?" do
      describe "when email_confirmed_at is blank" do
        it "returns false" do
          admin_user = create_admin_user(email_confirmed_at: nil)

          assert_not(admin_user.confirmed_email?)
        end
      end

      describe "when email_confirmed_at is present" do
        it "returns true" do
          admin_user = create_admin_user(email_confirmed_at: Time.current)

          assert(admin_user.confirmed_email?)
        end
      end
    end

    describe "#unconfirmed_email?" do
      describe "when email_confirmed_at is blank" do
        it "returns true" do
          admin_user = create_admin_user(email_confirmed_at: nil)

          assert(admin_user.unconfirmed_email?)
        end
      end

      describe "when email_confirmed_at is present" do
        it "returns false" do
          admin_user = create_admin_user(email_confirmed_at: Time.current)

          assert_not(admin_user.unconfirmed_email?)
        end
      end
    end

    describe "#confirm_email!" do
      it "updates email_confirmed_at to the current time" do
        freeze_time do
          admin_user = create_admin_user(email_confirmed_at: nil)

          admin_user.confirm_email!

          assert_equal(Time.current, admin_user.email_confirmed_at)
        end
      end
    end

    describe "#unconfirm_email!" do
      it "updates email_confirmed_at to nil" do
        admin_user = create_admin_user(email_confirmed_at: Time.current)

        admin_user.unconfirm_email!

        assert_nil(admin_user.email_confirmed_at)
      end
    end
  end

  describe "HasLock" do
    describe "#locked?" do
      describe "when locked_at is blank" do
        it "returns false" do
          admin_user = create_admin_user(locked_at: nil)

          assert_not(admin_user.locked?)
        end
      end

      describe "when locked_at is present" do
        it "returns true" do
          admin_user = create_admin_user(locked_at: Time.current)

          assert(admin_user.locked?)
        end
      end
    end

    describe "#unlocked?" do
      describe "when locked_at is blank" do
        it "returns true" do
          admin_user = create_admin_user(locked_at: nil)

          assert(admin_user.unlocked?)
        end
      end

      describe "when locked_at is present" do
        it "returns false" do
          admin_user = create_admin_user(locked_at: Time.current)

          assert_not(admin_user.unlocked?)
        end
      end
    end

    describe "#lock_access!" do
      it "updates locked attributes" do
        freeze_time do
          admin_user = create_admin_user(locked_reason: nil, locked_comment: nil, locked_at: nil)

          admin_user.lock_access!("Bad Actor", "AdminUser did bad things")

          assert_equal("Bad Actor", admin_user.locked_reason)
          assert_equal("AdminUser did bad things", admin_user.locked_comment)
          assert_equal(Time.current, admin_user.locked_at)
        end
      end
    end

    describe "#unlock_access!" do
      it "set locked attributes to nil" do
        admin_user = create_admin_user(
          locked_reason: "Bad Actor",
          locked_comment: "AdminUser did bad things",
          locked_at: Time.current
        )

        admin_user.unlock_access!

        assert_nil(admin_user.locked_reason)
        assert_nil(admin_user.locked_comment)
        assert_nil(admin_user.locked_at)
      end
    end
  end

  describe "HasPassword" do
    it "has secure password" do
      admin_user = build_admin_user(email: "admin_user@upper.town", password: "abcd1234")

      assert(admin_user.password_digest.present?)
      assert_not_equal("abcd1234", admin_user.password_digest)

      admin_user.save!

      assert_equal(
        admin_user,
        described_class.authenticate_by(email: "admin_user@upper.town", password: "abcd1234")
      )
    end

    describe "validations" do
      it "validates password" do
        admin_user = build_admin_user(password: "")
        admin_user.validate
        assert_not(admin_user.errors.of_kind?(:password, :blank))

        admin_user = build_admin_user(password: "abcd")
        admin_user.validate
        assert(admin_user.errors.of_kind?(:password, :too_short))

        admin_user = build_admin_user(password: "abcd1234")
        admin_user.validate
        assert_not(admin_user.errors.of_kind?(:password, :too_short))
      end
    end

    describe "#reset_password!" do
      it "updates password and password_reset_at" do
        freeze_time do
          admin_user = create_admin_user(password_digest: nil)

          admin_user.reset_password!("abcd1234")

          assert(admin_user.password_digest.present?)
          assert_not_equal("abcd1234", admin_user.password_digest)
          assert_equal(Time.current, admin_user.password_reset_at)

          assert_equal(
            admin_user,
            described_class.authenticate_by(email: admin_user.email, password: "abcd1234")
          )
        end
      end
    end
  end
end
