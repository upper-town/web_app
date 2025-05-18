# frozen_string_literal: true

require "test_helper"

class Servers::VerifyJobTest < ActiveSupport::TestCase
  let(:described_class) { Servers::VerifyJob }

  describe "#perform" do
    it "calls Verify for server" do
      server = create_server
      servers_verify = Servers::Verify.new(server)

      called = 0
      Servers::Verify.stub(:new, ->(arg) do
        called += 1
        assert_equal(arg, server)
        servers_verify
      end) do
        servers_verify.stub(:call, -> { called += 1 ; nil }) do
          described_class.new.perform(server)
        end
      end
      assert_equal(2, called)
    end
  end
end
