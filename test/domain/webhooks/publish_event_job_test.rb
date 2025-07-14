# frozen_string_literal: true

require "test_helper"

class Webhooks::PublishEventJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::PublishEventJob }

  describe "#perform" do
    describe "when PublishEvent result is a success" do
      it "does not enqueue any other job" do
        webhook_event = create_webhook_event

        called = 0
        Webhooks::PublishEvent.stub(:call, ->(arg) do
          called += 1
          assert_equal(webhook_event, arg)
          Webhooks::PublishEvent::Result.success
        end) do
          described_class.new.perform(webhook_event)
        end
        assert_equal(1, called)

        assert_no_enqueued_jobs(only: described_class)
      end
    end

    describe "when PublishEvent result is a failure" do
      describe "when result does not have a retry_in" do
        it "does not reenqueue job to publish the event later" do
          webhook_event = create_webhook_event

          called = 0
          Webhooks::PublishEvent.stub(:call, ->(arg) do
            called += 1
            assert_equal(webhook_event, arg)
            Webhooks::PublishEvent::Result.failure
          end) do
            described_class.new.perform(webhook_event)
          end
          assert_equal(1, called)

          assert_no_enqueued_jobs(only: described_class)
        end
      end

      describe "when result has a retry_in" do
        it "reenqueues job to publish the event later" do
          freeze_time do
            webhook_event = create_webhook_event

            called = 0
            Webhooks::PublishEvent.stub(:call, ->(arg) do
              called += 1
              assert_equal(webhook_event, arg)
              Webhooks::PublishEvent::Result.failure(nil, retry_in: 120)
            end) do
              described_class.new.perform(webhook_event)
            end
            assert_equal(1, called)

            assert_enqueued_with(job: described_class, args: [webhook_event], at: 120.seconds.from_now)
          end
        end
      end
    end
  end
end
