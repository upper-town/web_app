# frozen_string_literal: true

require "test_helper"

class Webhooks::PublishEventTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::PublishEvent }

  describe "#call" do
    describe "when webhook_event has already failed" do
      it "returns failure and does not try to publish" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          disabled_at: nil,
          event_types: ["test.event"],
          secret: "aaaaaaaa"
        )
        webhook_event = create_webhook_event(
          config: webhook_config,
          type: "test.event",
          status: "failed"
        )
        publish_event_request = stub_publish_event_request(
          url: "https://game.company.com/webhook_events"
        )

        result = described_class.new(webhook_event).call

        assert_not_requested(publish_event_request)
        assert_no_enqueued_jobs(only: Webhooks::UpdateDeliveredEventJob)

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("Could not retry event: it has been retried and failed multiple times") })
      end
    end

    describe "when webhook_event has already been delivered" do
      it "returns failure and does not try to publish" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          disabled_at: nil,
          event_types: ["test.event"],
          secret: "aaaaaaaa"
        )
        webhook_event = create_webhook_event(
          config: webhook_config,
          type: "test.event",
          status: "delivered"
        )
        publish_event_request = stub_publish_event_request(
          url: "https://game.company.com/webhook_events"
        )

        result = described_class.new(webhook_event).call

        assert_not_requested(publish_event_request)
        assert_no_enqueued_jobs(only: Webhooks::UpdateDeliveredEventJob)

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("Cannot retry event: it has been delivered already") })
      end
    end

    describe "when webhook_event config is not subscribed to event_type anymore" do
      it "returns failure with retry_in and does not try to publish" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          disabled_at: nil,
          event_types: ["something.else"],
          secret: "aaaaaaaa"
        )
        webhook_event = create_webhook_event(
          config: webhook_config,
          type: "test.event",
          status: "pending"
        )
        publish_event_request = stub_publish_event_request(
          url: "https://game.company.com/webhook_events"
        )

        result = described_class.new(webhook_event).call

        assert_not_requested(publish_event_request)
        assert_no_enqueued_jobs(only: Webhooks::UpdateDeliveredEventJob)

        webhook_event.reload
        assert_equal(1, webhook_event.failed_attempts)
        assert_equal("Could not find config that is subscribed to this event type at the time of publishing it", webhook_event.metadata["notice"])
        assert_equal("retry", webhook_event.status)

        assert(result.failure?)
        assert(result.errors[:base].any? { it.include?("May retry event: #{webhook_event.metadata['notice']}") })
        assert(result.retry_in.present?)
      end
    end

    describe "when webhook_event config is disabled" do
      it "returns failure with retry_in and does not try to publish" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          disabled_at: Time.current,
          event_types: ["test.event"],
          secret: "aaaaaaaa"
        )
        webhook_event = create_webhook_event(
          config: webhook_config,
          type: "test.event",
          status: "pending"
        )
        publish_event_request = stub_publish_event_request(
          url: "https://game.company.com/webhook_events"
        )

        result = described_class.new(webhook_event).call

        assert_not_requested(publish_event_request)
        assert_no_enqueued_jobs(only: Webhooks::UpdateDeliveredEventJob)

        webhook_event.reload
        assert_equal(1, webhook_event.failed_attempts)
        assert_equal("Could not find an enabled config for this event type at the time of publishing it", webhook_event.metadata["notice"])
        assert_equal("retry", webhook_event.status)

        assert(result.failure?)
        assert(result.errors[:base].any? { it.match?(/May retry event: #{webhook_event.metadata['notice']}/) })
        assert(result.retry_in.present?)
      end
    end

    describe "when event and config are OK" do
      describe "when request to publish responds with 4xx status" do
        it "returns failure with retry_in" do
          freeze_time do
            webhook_config = create_webhook_config(
              method: "POST",
              url: "https://game.company.com/webhook_events",
              disabled_at: nil,
              event_types: ["test.event"],
              secret: "aaaaaaaa"
            )
            webhook_event = create_webhook_event(
              config: webhook_config,
              type: "test.event",
              status: "pending",
              data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
              last_published_at: nil,
              failed_attempts: 0,
              metadata: {}
            )
            expected_body = {
              "webhook_event" => {
                "type" => "test.event",
                "data" => webhook_event.data,
                "last_published_at" => Time.current.iso8601,
                "failed_attempts" => 0
              }
            }.to_json
            expected_headers = {
              "Content-Type" => "application/json",
              "X-Signature" => OpenSSL::HMAC.hexdigest("sha256", "aaaaaaaa", expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: "https://game.company.com/webhook_events",
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_status: 400
            )

            result = described_class.new(webhook_event).call

            assert_requested(publish_event_request)
            assert_no_enqueued_jobs(only: Webhooks::UpdateDeliveredEventJob)

            webhook_event.reload
            assert_equal("retry", webhook_event.status)
            assert_equal(Time.current, webhook_event.last_published_at)
            assert_equal(1, webhook_event.failed_attempts)
            assert_match(/Request failed/, webhook_event.metadata["notice"])

            assert(result.failure?)
            assert(result.errors[:base].any? { it.include?("May retry event") })
            assert(result.retry_in.present?)
          end
        end
      end

      describe "when request to publish responds with 5xx status" do
        it "returns failure with retry_in" do
          freeze_time do
            webhook_config = create_webhook_config(
              method: "POST",
              url: "https://game.company.com/webhook_events",
              disabled_at: nil,
              event_types: ["test.event"],
              secret: "aaaaaaaa"
            )
            webhook_event = create_webhook_event(
              config: webhook_config,
              type: "test.event",
              status: "pending",
              data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
              last_published_at: nil,
              failed_attempts: 0,
              metadata: {}
            )
            expected_body = {
              "webhook_event" => {
                "type" => "test.event",
                "data" => webhook_event.data,
                "last_published_at" => Time.current.iso8601,
                "failed_attempts" => 0
              }
            }.to_json
            expected_headers = {
              "Content-Type" => "application/json",
              "X-Signature" => OpenSSL::HMAC.hexdigest("sha256", "aaaaaaaa", expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: "https://game.company.com/webhook_events",
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_status: 500
            )

            result = described_class.new(webhook_event).call

            assert_requested(publish_event_request)
            assert_no_enqueued_jobs(only: Webhooks::UpdateDeliveredEventJob)

            webhook_event.reload
            assert_equal("retry", webhook_event.status)
            assert_equal(Time.current, webhook_event.last_published_at)
            assert_equal(1, webhook_event.failed_attempts)
            assert_match(/Request failed/, webhook_event.metadata["notice"])

            assert(result.failure?)
            assert(result.errors[:base].any? { it.include?("May retry event") })
            assert(result.retry_in.present?)
          end
        end
      end

      describe "when request to publish times out" do
        it "returns failure with retry_in" do
          freeze_time do
            webhook_config = create_webhook_config(
              method: "POST",
              url: "https://game.company.com/webhook_events",
              disabled_at: nil,
              event_types: ["test.event"],
              secret: "aaaaaaaa"
            )
            webhook_event = create_webhook_event(
              config: webhook_config,
              type: "test.event",
              status: "pending",
              data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
              last_published_at: nil,
              failed_attempts: 0,
              metadata: {}
            )
            expected_body = {
              "webhook_event" => {
                "type" => "test.event",
                "data" => webhook_event.data,
                "last_published_at" => Time.current.iso8601,
                "failed_attempts" => 0
              }
            }.to_json
            expected_headers = {
              "Content-Type" => "application/json",
              "X-Signature" => OpenSSL::HMAC.hexdigest("sha256", "aaaaaaaa", expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: "https://game.company.com/webhook_events",
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_timeout: true
            )

            result = described_class.new(webhook_event).call

            assert_requested(publish_event_request)
            assert_no_enqueued_jobs(only: Webhooks::UpdateDeliveredEventJob)

            webhook_event.reload
            assert_equal("retry", webhook_event.status)
            assert_equal(Time.current, webhook_event.last_published_at)
            assert_equal(1, webhook_event.failed_attempts)
            assert_match(/Connection failed/, webhook_event.metadata["notice"])

            assert(result.failure?)
            assert(result.errors[:base].any? { it.include?("May retry event") })
            assert(result.retry_in.present?)
          end
        end
      end

      describe "when there are multiple failures" do
        it "returns failure with retry_in nil and status failed" do
          freeze_time do
            webhook_config = create_webhook_config(
              method: "POST",
              url: "https://game.company.com/webhook_events",
              disabled_at: nil,
              event_types: ["test.event"],
              secret: "aaaaaaaa"
            )
            webhook_event = create_webhook_event(
              config: webhook_config,
              type: "test.event",
              status: "pending",
              data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
              last_published_at: nil,
              failed_attempts: 24,
              metadata: {}
            )
            expected_body = {
              "webhook_event" => {
                "type" => "test.event",
                "data" => webhook_event.data,
                "last_published_at" => Time.current.iso8601,
                "failed_attempts" => 24
              }
            }.to_json
            expected_headers = {
              "Content-Type" => "application/json",
              "X-Signature" => OpenSSL::HMAC.hexdigest("sha256", "aaaaaaaa", expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: "https://game.company.com/webhook_events",
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_status: 400
            )

            result = described_class.new(webhook_event).call

            assert_requested(publish_event_request)
            assert_no_enqueued_jobs(only: Webhooks::UpdateDeliveredEventJob)

            webhook_event.reload
            assert_equal("failed", webhook_event.status)
            assert_equal(Time.current, webhook_event.last_published_at)
            assert_equal(25, webhook_event.failed_attempts)
            assert_match(/Request failed/, webhook_event.metadata["notice"])

            assert(result.failure?)
            assert(result.errors[:base].any? { it.include?("May retry event") })
            assert_nil(result.retry_in)
          end
        end
      end

      describe "when request to publish responds with 2xx status" do
        it "returns success" do
          freeze_time do
            webhook_config = create_webhook_config(
              method: "POST",
              url: "https://game.company.com/webhook_events",
              disabled_at: nil,
              event_types: ["test.event"],
              secret: "aaaaaaaa"
            )
            webhook_event = create_webhook_event(
              config: webhook_config,
              type: "test.event",
              status: "pending",
              data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
              last_published_at: nil,
              failed_attempts: 0,
              metadata: {}
            )
            expected_body = {
              "webhook_event" => {
                "type" => "test.event",
                "data" => webhook_event.data,
                "last_published_at" => Time.current.iso8601,
                "failed_attempts" => 0
              }
            }.to_json
            expected_headers = {
              "Content-Type" => "application/json",
              "X-Signature" => OpenSSL::HMAC.hexdigest("sha256", "aaaaaaaa", expected_body)
            }
            publish_event_request = stub_publish_event_request(
              url: "https://game.company.com/webhook_events",
              method: :post,
              headers: expected_headers,
              body: expected_body,
              response_status: 200
            )

            result = described_class.new(webhook_event).call

            assert_requested(publish_event_request)
            assert_enqueued_with(job: Webhooks::UpdateDeliveredEventJob, args: [webhook_event])

            webhook_event.reload
            assert_equal("pending", webhook_event.status)
            assert_equal(Time.current, webhook_event.last_published_at)
            assert_equal(0, webhook_event.failed_attempts)
            assert_equal({}, webhook_event.metadata)

            assert(result.success?)
          end
        end

        describe "other config methods" do
          it "works with PUT" do
            freeze_time do
              webhook_config = create_webhook_config(
                method: "PUT",
                url: "https://game.company.com/webhook_events",
                disabled_at: nil,
                event_types: ["test.event"],
                secret: "aaaaaaaa"
              )
              webhook_event = create_webhook_event(
                config: webhook_config,
                type: "test.event",
                status: "pending",
                data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
                last_published_at: nil,
                failed_attempts: 0,
                metadata: {}
              )
              expected_body = {
                "webhook_event" => {
                  "type" => "test.event",
                  "data" => webhook_event.data,
                  "last_published_at" => Time.current.iso8601,
                  "failed_attempts" => 0
                }
              }.to_json
              expected_headers = {
                "Content-Type" => "application/json",
                "X-Signature" => OpenSSL::HMAC.hexdigest("sha256", "aaaaaaaa", expected_body)
              }
              publish_event_request = stub_publish_event_request(
                url: "https://game.company.com/webhook_events",
                method: :put,
                headers: expected_headers,
                body: expected_body,
                response_status: 200
              )

              result = described_class.new(webhook_event).call

              assert_requested(publish_event_request)
              assert_enqueued_with(job: Webhooks::UpdateDeliveredEventJob, args: [webhook_event])

              webhook_event.reload
              assert_equal("pending", webhook_event.status)
              assert_equal(Time.current, webhook_event.last_published_at)
              assert_equal(0, webhook_event.failed_attempts)
              assert_equal({}, webhook_event.metadata)

              assert(result.success?)
            end
          end

          it "works with PATCH" do
            freeze_time do
              webhook_config = create_webhook_config(
                method: "PATCH",
                url: "https://game.company.com/webhook_events",
                disabled_at: nil,
                event_types: ["test.event"],
                secret: "aaaaaaaa"
              )
              webhook_event = create_webhook_event(
                config: webhook_config,
                type: "test.event",
                status: "pending",
                data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
                last_published_at: nil,
                failed_attempts: 0,
                metadata: {}
              )
              expected_body = {
                "webhook_event" => {
                  "type" => "test.event",
                  "data" => webhook_event.data,
                  "last_published_at" => Time.current.iso8601,
                  "failed_attempts" => 0
                }
              }.to_json
              expected_headers = {
                "Content-Type" => "application/json",
                "X-Signature" => OpenSSL::HMAC.hexdigest("sha256", "aaaaaaaa", expected_body)
              }
              publish_event_request = stub_publish_event_request(
                url: "https://game.company.com/webhook_events",
                method: :patch,
                headers: expected_headers,
                body: expected_body,
                response_status: 200
              )

              result = described_class.new(webhook_event).call

              assert_requested(publish_event_request)
              assert_enqueued_with(job: Webhooks::UpdateDeliveredEventJob, args: [webhook_event])

              webhook_event.reload
              assert_equal("pending", webhook_event.status)
              assert_equal(Time.current, webhook_event.last_published_at)
              assert_equal(0, webhook_event.failed_attempts)
              assert_equal({}, webhook_event.metadata)

              assert(result.success?)
            end
          end
        end
      end
    end
  end

  def stub_publish_event_request(
    url:,
    method: :any,
    headers: nil,
    body: nil,
    response_status: 200,
    response_headers: { "Content-Type" => "text/plain" },
    response_body: nil,
    response_timeout: false
  )
    request = stub_request(method, url)
    request = request.with(headers:) if !headers.nil?
    request = request.with(body:) if !body.nil?

    if response_timeout
      request.to_timeout
    else
      request.to_return(
        status: response_status,
        headers: response_headers,
        body: response_body.to_json
      )
    end
  end
end
