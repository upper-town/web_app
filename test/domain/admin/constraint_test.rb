# frozen_string_literal: true

require "test_helper"

class Admin::ConstraintTest < ActiveSupport::TestCase
  let(:described_class) { Admin::Constraint }

  describe "#matches?" do
    describe "when admin_user is signed_in" do
      it "returns true" do
        admin_user = create_admin_user
        request = build_custom_request(admin_user, signed_in: true)

        assert(described_class.new.matches?(request))
      end
    end

    describe "when admin_user is not signed_in" do
      it "returns false" do
        admin_user = create_admin_user
        request = build_custom_request(admin_user, signed_in: false)

        assert_not(described_class.new.matches?(request))
      end
    end
  end

  def build_custom_request(admin_user, signed_in:)
    request = build_request

    if signed_in
      token, token_digest, token_last_four = TokenGenerator::AdminSession.generate
      create_admin_session(
        admin_user:,
        token_digest:,
        token_last_four:,
        expires_at: 1.month.from_now
      )
      request.cookie_jar["admin_session"] = { token: }.to_json
    end

    request
  end
end
