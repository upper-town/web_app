# frozen_string_literal: true

require "test_helper"

class AdminTokenTest < ActiveSupport::TestCase
  let(:described_class) { AdminToken }

  describe "associations" do
    it "belongs to admin_user" do
      admin_token = create_admin_token

      assert(admin_token.admin_user.present?)
    end
  end

  describe ".find_by_token" do
    describe "when token value is blank" do
      it "returns nil" do
        assert_nil(described_class.find_by_token(" "))
        assert_nil(described_class.find_by_token(" ", true))
      end
    end

    describe "when token is not found by its token_digest" do
      it "returns nil" do
        assert_nil(described_class.find_by_token("abcdef123456"))
        assert_nil(described_class.find_by_token("abcdef123456", true))
      end
    end

    describe "include_expired false" do
      describe "when token is found by its token_digest but is expired" do
        it "returns nil" do
          token = "abcdef123456"
          _existing_admin_token = create_admin_token(
            token_digest: TokenGenerator::Admin.digest(token),
            expires_at: 2.days.ago
          )

          assert_nil(described_class.find_by_token(token))
        end
      end

      describe "when token is found by its token_digest and is not expired" do
        it "returns Token record" do
          token = "abcdef123456"
          existing_admin_token = create_admin_token(
            token_digest: TokenGenerator::Admin.digest(token),
            expires_at: 2.days.from_now
          )

          assert_equal(existing_admin_token, described_class.find_by_token(token))
        end
      end
    end

    describe "include_expired true" do
      describe "when token is found by its token_digest" do
        it "returns AdminToken record" do
          [
            ["aaaa1111", 2.days.ago],
            ["bbbb2222", 2.days.from_now]
          ].each do |token, expires_at|
            existing_admin_token = create_admin_token(
              token_digest: TokenGenerator::Admin.digest(token),
              expires_at: expires_at
            )

            assert_equal(existing_admin_token, described_class.find_by_token(token, true))
          end
        end
      end
    end
  end

  describe ".expired" do
    it "returns expired AdminToken records" do
      freeze_time do
        admin_token1 = create_admin_token(expires_at: 1.second.ago)
        admin_token2 = create_admin_token(expires_at: Time.current)
        _admin_token3 = create_admin_token(expires_at: 1.day.from_now)

        assert_equal(
          [admin_token1, admin_token2].sort,
          described_class.expired.sort
        )
      end
    end
  end

  describe ".not_expired" do
    it "returns not expired AdminToken records" do
      freeze_time do
        _admin_token1 = create_admin_token(expires_at: 1.second.ago)
        _admin_token2 = create_admin_token(expires_at: Time.current)
        admin_token3 = create_admin_token(expires_at: 1.day.from_now)

        assert_equal(
          [admin_token3].sort,
          described_class.not_expired.sort
        )
      end
    end
  end

  describe "#expired?" do
    describe "when expires_at is in the past" do
      it "returns true" do
        freeze_time do
          admin_token = create_admin_token(expires_at: 1.second.ago)

          assert(admin_token.expired?)
        end
      end
    end

    describe "when expires_at is in the present" do
      it "returns true" do
        freeze_time do
          admin_token = create_admin_token(expires_at: Time.current)

          assert(admin_token.expired?)
        end
      end
    end

    describe "when expires_at is in the future" do
      it "returns false" do
        freeze_time do
          admin_token = create_admin_token(expires_at: 1.second.from_now)

          assert_not(admin_token.expired?)
        end
      end
    end
  end

  describe "#expire!" do
    it "sets expires_at to the past" do
      freeze_time do
        admin_token = create_admin_token(expires_at: 1.day.from_now)

        admin_token.expire!

        assert_equal(1.day.ago, admin_token.expires_at)
      end
    end
  end
end
