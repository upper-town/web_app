# frozen_string_literal: true

require "test_helper"

class ServerWebhooks::PublishEventJobTest < ActiveSupport::TestCase
  let(:described_class) { ServerWebhooks::PublishEventJob }

  describe "#perform" do
    describe "when PublishEvent result is a success" do
      it "does not enqueue any other job" do
        server_webhook_event = create_server_webhook_event

        called = 0
        ServerWebhooks::PublishEvent.stub(:call, ->(arg) do
          called += 1
          assert(server_webhook_event, arg)
          ServerWebhooks::PublishEvent::Result.success
        end) do
          described_class.new.perform(server_webhook_event)
        end
        assert_equal(1, called)

        assert_no_enqueued_jobs(only: described_class)
      end
    end

    describe "when PublishEvent result is a failure" do
      describe "when result does not have a retry_in" do
        it "does not reenqueue job to publish the event later" do
          server_webhook_event = create_server_webhook_event

          called = 0
          ServerWebhooks::PublishEvent.stub(:call, ->(arg) do
            called += 1
            assert_equal(server_webhook_event, arg)
            ServerWebhooks::PublishEvent::Result.failure
          end) do
            described_class.new.perform(server_webhook_event)
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: described_class)
        end
      end

      describe "when result has a retry_in" do
        it "reenqueues job to publish the event later" do
          freeze_time do
            server_webhook_event = create_server_webhook_event

            called = 0
            ServerWebhooks::PublishEvent.stub(:call, ->(arg) do
              called += 1
              assert_equal(server_webhook_event, arg)
              ServerWebhooks::PublishEvent::Result.failure(nil, retry_in: 120)
            end) do
              described_class.new.perform(server_webhook_event)
            end
            assert_equal(1, called)

            assert_enqueued_with(job: described_class, args: [server_webhook_event], at: 120.seconds.from_now)
          end
        end
      end
    end
  end
end
