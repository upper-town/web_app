# frozen_string_literal: true

require "test_helper"

class SessionTest < ActiveSupport::TestCase
  let(:described_class) { Session }

  describe "associations" do
    it "belongs to user" do
      session = create_session

      assert(session.user.present?)
    end
  end

  describe ".find_by_token" do
    describe "when token is blank" do
      it "returns nil" do
        assert_nil(described_class.find_by_token(" "))
      end
    end

    describe "when Session is not found" do
      it "returns nil" do
        assert_nil(described_class.find_by_token("abcdef123456"))
      end
    end

    describe "when Session is found" do
      it "returns Session record" do
        session = create_session(token_digest: TokenGenerator::Session.digest("abcdef123456"))

        assert_equal(session, described_class.find_by_token("abcdef123456"))
      end
    end
  end

  describe "#expired?" do
    describe "when expires_at is the current time" do
      it "returns true" do
        freeze_time do
          session = create_session(expires_at: Time.current)

          assert(session.expired?)
        end
      end
    end

    describe "when expires_at is less than the current time" do
      it "returns true" do
        freeze_time do
          session = create_session(expires_at: 1.second.ago)

          assert(session.expired?)
        end
      end
    end

    describe "when expires_at is greater than the current time" do
      it "returns false" do
        freeze_time do
          session = create_session(expires_at: 1.second.from_now)

          assert_not(session.expired?)
        end
      end
    end
  end
end
