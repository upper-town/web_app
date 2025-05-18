# frozen_string_literal: true

require "test_helper"

class Admin::UsersQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::UsersQuery }

  describe "#call" do
    it "returns all users ordered by id desc" do
      user1 = create_user
      user2 = create_user
      user3 = create_user

      assert_equal(
        [
          user3,
          user2,
          user1
        ],
        described_class.new.call
      )
    end
  end
end
