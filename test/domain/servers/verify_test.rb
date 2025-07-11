# frozen_string_literal: true

require "test_helper"

class Servers::VerifyTest < ActiveSupport::TestCase
  let(:described_class) { Servers::Verify }

  describe "#call" do
    describe "when VerifyAccounts::Perform suceeds" do
      it "updates server as verified" do
        freeze_time do
          server = create_server(verified_at: nil, verified_notice: "something")
          verify_accounts_perform = Servers::VerifyAccounts::Perform.new(server)

          called = 0
          Servers::VerifyAccounts::Perform.stub(:new, ->(arg) do
            called += 1
            assert_equal(arg, server)
            verify_accounts_perform
          end) do
            verify_accounts_perform.stub(:call, ->(_current_time) { called += 1 ; Result.success }) do
              described_class.new(server).call
            end
          end
          assert_equal(2, called)

          server.reload
          assert_equal(Time.current, server.verified_at)
          assert_equal("", server.verified_notice)
        end
      end
    end

    describe "when VerifyAccounts::Perform fails" do
      it "updates server as not verified" do
        server = create_server(verified_at: Time.current, verified_notice: "")
        verify_accounts_perform = Servers::VerifyAccounts::Perform.new(server)

        called = 0
        Servers::VerifyAccounts::Perform.stub(:new, ->(arg) do
          called += 1
          assert_equal(arg, server)
          verify_accounts_perform
        end) do
          verify_accounts_perform.stub(:call, ->(_current_time) do
            called += 1
            Result.failure(["an error", "another error"])
          end) do
            described_class.new(server).call
          end
        end
        assert_equal(2, called)

        server.reload
        assert_nil(server.verified_at)
        assert_equal("an error; another error", server.verified_notice)
      end
    end
  end
end
