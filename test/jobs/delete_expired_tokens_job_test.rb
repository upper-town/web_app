# frozen_string_literal: true

require "test_helper"

class DeleteExpiredTokensJobTest < ActiveSupport::TestCase
  let(:described_class) { DeleteExpiredTokensJob }

  describe "#perform" do
    it "deletes all expired Token and AdminToken records" do
      token1 = create_token(expires_at: 2.days.ago)
      token2 = create_token(expires_at: 2.days.from_now)
      admin_token1 = create_admin_token(expires_at: 2.days.ago)
      admin_token2 = create_admin_token(expires_at: 2.days.from_now)

      assert_difference(-> { Token.count }, -1) do
        assert_difference(-> { AdminToken.count }, -1) do
          described_class.new.perform
        end
      end

      assert(Token.find_by(id: token1.id).blank?)
      assert_equal(token2, Token.find_by(id: token2.id))
      assert(AdminToken.find_by(id: admin_token1.id).blank?)
      assert_equal(admin_token2, AdminToken.find_by(id: admin_token2.id))
    end
  end
end
