# frozen_string_literal: true

require "test_helper"

class TokenTest < ActiveSupport::TestCase
  let(:described_class) { Token }

  describe "associations" do
    it "belongs to user" do
      token = create_token

      assert(token.user.present?)
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
          _existing_token = create_token(
            token_digest: TokenGenerator.digest(token),
            expires_at: 2.days.ago
          )

          assert_nil(described_class.find_by_token(token))
        end
      end

      describe "when token is found by its token_digest and is not expired" do
        it "returns Token record" do
          token = "abcdef123456"
          existing_token = create_token(
            token_digest: TokenGenerator.digest(token),
            expires_at: 2.days.from_now
          )

          assert_equal(existing_token, described_class.find_by_token(token))
        end
      end
    end

    describe "include_expired true" do
      describe "when token is found by its token_digest" do
        it "returns Token record" do
          [
            ["aaaa1111", 2.days.ago],
            ["bbbb2222", 2.days.from_now]
          ].each do |token, expires_at|
            existing_token = create_token(
              token_digest: TokenGenerator.digest(token),
              expires_at: expires_at
            )

            assert_equal(existing_token, described_class.find_by_token(token, true))
          end
        end
      end
    end
  end

  describe ".expired" do
    it "returns expired Token records" do
      freeze_time do
        token1 = create_token(expires_at: 1.second.ago)
        token2 = create_token(expires_at: Time.current)
        _token3 = create_token(expires_at: 1.day.from_now)

        assert_equal(
          [token1, token2].sort,
          described_class.expired.sort
        )
      end
    end
  end

  describe ".not_expired" do
    it "returns not expired Token records" do
      freeze_time do
        _token1 = create_token(expires_at: 1.second.ago)
        _token2 = create_token(expires_at: Time.current)
        token3 = create_token(expires_at: 1.day.from_now)

        assert_equal([token3], described_class.not_expired)
      end
    end
  end

  describe "#expired?" do
    describe "when expires_at is in the past" do
      it "returns true" do
        freeze_time do
          token = create_token(expires_at: 1.second.ago)

          assert(token.expired?)
        end
      end
    end

    describe "when expires_at is in the present" do
      it "returns true" do
        freeze_time do
          token = create_token(expires_at: Time.current)

          assert(token.expired?)
        end
      end
    end

    describe "when expires_at is in the future" do
      it "returns false" do
        freeze_time do
          token = create_token(expires_at: 1.second.from_now)

          assert_not(token.expired?)
        end
      end
    end
  end

  describe "#expire!" do
    it "sets expires_at to the past" do
      freeze_time do
        token = create_token(expires_at: 1.day.from_now)

        token.expire!

        assert_equal(1.day.ago, token.expires_at)
      end
    end
  end
end
