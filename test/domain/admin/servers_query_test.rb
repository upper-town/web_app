# frozen_string_literal: true

require "test_helper"

class Admin::ServersQueryTest < ActiveSupport::TestCase
  let(:described_class) { Admin::ServersQuery }

  describe "#call" do
    it "returns all servers ordered by id desc" do
      server1 = create_server
      server2 = create_server
      server3 = create_server

      assert_equal(
        [
          server3,
          server2,
          server1
        ],
        described_class.new.call
      )
    end
  end
end
