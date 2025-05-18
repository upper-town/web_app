# frozen_string_literal: true

require "test_helper"

class AdminSessionTest < ActiveSupport::TestCase
  let(:described_class) { AdminSession }

  describe "associations" do
    it "belongs to admin_user" do
      admin_session = create_admin_session

      assert(admin_session.admin_user.present?)
    end
  end

  describe ".find_by_token" do
    describe "when token is blank" do
      it "returns nil" do
        assert_nil(described_class.find_by_token(" "))
      end
    end

    describe "when AdminSession is not found" do
      it "returns nil" do
        assert_nil(described_class.find_by_token("abcdef123456"))
      end
    end

    describe "when AdminSession is found" do
      it "returns AdminSession record" do
        admin_session = create_admin_session(token_digest: TokenGenerator::AdminSession.digest("abcdef123456"))

        assert_equal(admin_session, described_class.find_by_token("abcdef123456"))
      end
    end
  end

  describe "#expired?" do
    describe "when expires_at is the current time" do
      it "returns true" do
        freeze_time do
          admin_session = create_admin_session(expires_at: Time.current)

          assert(admin_session.expired?)
        end
      end
    end

    describe "when expires_at is less than the current time" do
      it "returns true" do
        freeze_time do
          admin_session = create_admin_session(expires_at: 1.second.ago)

          assert(admin_session.expired?)
        end
      end
    end

    describe "when expires_at is greater than the current time" do
      it "returns false" do
        freeze_time do
          admin_session = create_admin_session(expires_at: 1.second.from_now)

          assert_not(admin_session.expired?)
        end
      end
    end
  end
end
