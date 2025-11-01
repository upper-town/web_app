# frozen_string_literal: true

require "test_helper"

class Webhooks::PublishBatchJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::PublishBatchJob }

  describe "#perform" do
    describe "when webhook_batch status is not 'queued'" do
      it "raises an error" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(
          config: webhook_config,
          status: "delivered"
        )
        webhook_request = stub_webhook_request(
          url: "https://game.company.com/webhook_events",
          method: :post,
          response_status: 200
        )

        error = assert_raises(StandardError) do
          described_class.new.perform(webhook_batch)
        end

        assert_not_requested(webhook_request)
        assert_match(/invalid webhook_batch.status: delivered/, error.message)
      end
    end

    describe "when webhook request responds with 4xx status" do
      it "raises an error" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(
          config: webhook_config,
          status: "queued",
          failed_attempts: 5
        )
        webhook_event1 = create_webhook_event(
          uuid: "88888888-8888-8888-8888-888888888888",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          metadata: {},
          created_at: "2025-01-01T12:00:01Z"
        )
        webhook_event2 = create_webhook_event(
          uuid: "99999999-9999-9999-9999-999999999999",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          metadata: {},
          created_at: "2025-01-01T12:00:02Z"
        )
        expected_body = [
          {
            "uuid" => webhook_event1.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:01.000Z",
          },
          {
            "uuid" => webhook_event2.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:02.000Z",
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "3f6d4da98e9ed3d710cb88aa525577900b0f30f75aced80e0ffd5de8b0a76c43"
        }
        webhook_request = stub_webhook_request(
          url: "https://game.company.com/webhook_events",
          method: :post,
          headers: expected_headers,
          body: expected_body,
          response_status: 400
        )

        assert_raises(Faraday::BadRequestError) do
          described_class.new.perform(webhook_batch)
        end

        assert_requested(webhook_request)
        webhook_batch.reload
        assert(webhook_batch.queued?)
        assert_equal(6, webhook_batch.failed_attempts)
        assert_match(/Faraday::BadRequestError/, webhook_batch.metadata["failed_attempts"]["6"])
      end
    end

    describe "when webhook request responds with 5xx status" do
      it "raises an error" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(
          config: webhook_config,
          status: "queued",
          failed_attempts: 5
        )
        webhook_event1 = create_webhook_event(
          uuid: "88888888-8888-8888-8888-888888888888",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          metadata: {},
          created_at: "2025-01-01T12:00:01Z"
        )
        webhook_event2 = create_webhook_event(
          uuid: "99999999-9999-9999-9999-999999999999",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          metadata: {},
          created_at: "2025-01-01T12:00:02Z"
        )
        expected_body = [
          {
            "uuid" => webhook_event1.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:01.000Z",
          },
          {
            "uuid" => webhook_event2.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:02.000Z",
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "3f6d4da98e9ed3d710cb88aa525577900b0f30f75aced80e0ffd5de8b0a76c43"
        }
        webhook_request = stub_webhook_request(
          url: "https://game.company.com/webhook_events",
          method: :post,
          headers: expected_headers,
          body: expected_body,
          response_status: 500
        )

        assert_raises(Faraday::ServerError) do
          described_class.new.perform(webhook_batch)
        end

        assert_requested(webhook_request)
        webhook_batch.reload
        assert(webhook_batch.queued?)
        assert_equal(6, webhook_batch.failed_attempts)
        assert_match(/Faraday::ServerError/, webhook_batch.metadata["failed_attempts"]["6"])
      end
    end

    describe "when webhook request times out" do
      it "raises an error" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(
          config: webhook_config,
          status: "queued",
          failed_attempts: 5
        )
        webhook_event1 = create_webhook_event(
          uuid: "88888888-8888-8888-8888-888888888888",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          metadata: {},
          created_at: "2025-01-01T12:00:01Z"
        )
        webhook_event2 = create_webhook_event(
          uuid: "99999999-9999-9999-9999-999999999999",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          metadata: {},
          created_at: "2025-01-01T12:00:02Z"
        )
        expected_body = [
          {
            "uuid" => webhook_event1.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:01.000Z",
          },
          {
            "uuid" => webhook_event2.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:02.000Z",
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "3f6d4da98e9ed3d710cb88aa525577900b0f30f75aced80e0ffd5de8b0a76c43"
        }
        webhook_request = stub_webhook_request(
          url: "https://game.company.com/webhook_events",
          method: :post,
          headers: expected_headers,
          body: expected_body,
          response_status: 200,
          response_timeout: true
        )

        assert_raises(Faraday::ConnectionFailed) do
          described_class.new.perform(webhook_batch)
        end

        assert_requested(webhook_request)
        webhook_batch.reload
        assert(webhook_batch.queued?)
        assert_equal(6, webhook_batch.failed_attempts)
        assert_match(/Faraday::ConnectionFailed/, webhook_batch.metadata["failed_attempts"]["6"])
      end
    end

    describe "when webhook request failed multiple times" do
      it "raises an error and set status 'failed'" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(
          config: webhook_config,
          status: "queued",
          failed_attempts: 24
        )
        webhook_event1 = create_webhook_event(
          uuid: "88888888-8888-8888-8888-888888888888",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          metadata: {},
          created_at: "2025-01-01T12:00:01Z"
        )
        webhook_event2 = create_webhook_event(
          uuid: "99999999-9999-9999-9999-999999999999",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          metadata: {},
          created_at: "2025-01-01T12:00:02Z"
        )
        expected_body = [
          {
            "uuid" => webhook_event1.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:01.000Z",
          },
          {
            "uuid" => webhook_event2.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:02.000Z",
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "3f6d4da98e9ed3d710cb88aa525577900b0f30f75aced80e0ffd5de8b0a76c43"
        }
        webhook_request = stub_webhook_request(
          url: "https://game.company.com/webhook_events",
          method: :post,
          headers: expected_headers,
          body: expected_body,
          response_status: 500
        )

        assert_raises(Faraday::ServerError) do
          described_class.new.perform(webhook_batch)
        end

        assert_requested(webhook_request)
        webhook_batch.reload
        assert(webhook_batch.failed?)
        assert_equal(25, webhook_batch.failed_attempts)
        assert_match(/Faraday::ServerError/, webhook_batch.metadata["failed_attempts"]["25"])
      end
    end

    describe "when webhook request responds with 2xx status" do
      it "does not raise any errors set status 'delivered'" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(
          config: webhook_config,
          status: "queued",
          failed_attempts: 5
        )
        webhook_event1 = create_webhook_event(
          uuid: "88888888-8888-8888-8888-888888888888",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          metadata: {},
          created_at: "2025-01-01T12:00:01Z"
        )
        webhook_event2 = create_webhook_event(
          uuid: "99999999-9999-9999-9999-999999999999",
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          metadata: {},
          created_at: "2025-01-01T12:00:02Z"
        )
        expected_body = [
          {
            "uuid" => webhook_event1.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:01.000Z",
          },
          {
            "uuid" => webhook_event2.uuid,
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "metadata" => {},
            "created_at" => "2025-01-01T12:00:02.000Z",
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "3f6d4da98e9ed3d710cb88aa525577900b0f30f75aced80e0ffd5de8b0a76c43"
        }
        webhook_request = stub_webhook_request(
          url: "https://game.company.com/webhook_events",
          method: :post,
          headers: expected_headers,
          body: expected_body,
          response_status: 200
        )

        assert_nothing_raised do
          described_class.new.perform(webhook_batch)
        end

        assert_requested(webhook_request)
        webhook_batch.reload
        assert(webhook_batch.delivered?)
        assert_equal(5, webhook_batch.failed_attempts)
        assert(webhook_batch.metadata.blank?)
      end

      describe "other config methods" do
        it "works with PUT" do
          webhook_config = create_webhook_config(
            method: "PUT",
            url: "https://game.company.com/webhook_events",
            secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
          )
          webhook_batch = create_webhook_batch(
            config: webhook_config,
            status: "queued",
            failed_attempts: 5
          )
          webhook_event1 = create_webhook_event(
            uuid: "88888888-8888-8888-8888-888888888888",
            config: webhook_config,
            batch: webhook_batch,
            type: "server_vote.created",
            data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
            metadata: {},
            created_at: "2025-01-01T12:00:01Z"
          )
          webhook_event2 = create_webhook_event(
            uuid: "99999999-9999-9999-9999-999999999999",
            config: webhook_config,
            batch: webhook_batch,
            type: "server_vote.created",
            data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
            metadata: {},
            created_at: "2025-01-01T12:00:02Z"
          )
          expected_body = [
            {
              "uuid" => webhook_event1.uuid,
              "type" => "server_vote.created",
              "data" => {
                "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
              },
              "metadata" => {},
              "created_at" => "2025-01-01T12:00:01.000Z",
            },
            {
              "uuid" => webhook_event2.uuid,
              "type" => "server_vote.created",
              "data" => {
                "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
              },
              "metadata" => {},
              "created_at" => "2025-01-01T12:00:02.000Z",
            }
          ].to_json
          expected_headers = {
            "Content-Type" => "application/json",
            "X-Signature"  => "3f6d4da98e9ed3d710cb88aa525577900b0f30f75aced80e0ffd5de8b0a76c43"
          }
          webhook_request = stub_webhook_request(
            url: "https://game.company.com/webhook_events",
            method: :put,
            headers: expected_headers,
            body: expected_body,
            response_status: 200
          )

          assert_nothing_raised do
            described_class.new.perform(webhook_batch)
          end

          assert_requested(webhook_request)
          webhook_batch.reload
          assert(webhook_batch.delivered?)
          assert_equal(5, webhook_batch.failed_attempts)
          assert(webhook_batch.metadata.blank?)
        end

        it "works with PATCH" do
          webhook_config = create_webhook_config(
            method: "PATCH",
            url: "https://game.company.com/webhook_events",
            secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
          )
          webhook_batch = create_webhook_batch(
            config: webhook_config,
            status: "queued",
            failed_attempts: 5
          )
          webhook_event1 = create_webhook_event(
            uuid: "88888888-8888-8888-8888-888888888888",
            config: webhook_config,
            batch: webhook_batch,
            type: "server_vote.created",
            data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
            metadata: {},
            created_at: "2025-01-01T12:00:01Z"
          )
          webhook_event2 = create_webhook_event(
            uuid: "99999999-9999-9999-9999-999999999999",
            config: webhook_config,
            batch: webhook_batch,
            type: "server_vote.created",
            data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
            metadata: {},
            created_at: "2025-01-01T12:00:02Z"
          )
          expected_body = [
            {
              "uuid" => webhook_event1.uuid,
              "type" => "server_vote.created",
              "data" => {
                "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
              },
              "metadata" => {},
              "created_at" => "2025-01-01T12:00:01.000Z",
            },
            {
              "uuid" => webhook_event2.uuid,
              "type" => "server_vote.created",
              "data" => {
                "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
              },
              "metadata" => {},
              "created_at" => "2025-01-01T12:00:02.000Z",
            }
          ].to_json
          expected_headers = {
            "Content-Type" => "application/json",
            "X-Signature"  => "3f6d4da98e9ed3d710cb88aa525577900b0f30f75aced80e0ffd5de8b0a76c43"
          }
          webhook_request = stub_webhook_request(
            url: "https://game.company.com/webhook_events",
            method: :patch,
            headers: expected_headers,
            body: expected_body,
            response_status: 200
          )

          assert_nothing_raised do
            described_class.new.perform(webhook_batch)
          end

          assert_requested(webhook_request)
          webhook_batch.reload
          assert(webhook_batch.delivered?)
          assert_equal(5, webhook_batch.failed_attempts)
          assert(webhook_batch.metadata.blank?)
        end
      end
    end
  end

  def stub_webhook_request(
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
    request = request.with(headers:) unless headers.nil?
    request = request.with(body:) unless body.nil?

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
