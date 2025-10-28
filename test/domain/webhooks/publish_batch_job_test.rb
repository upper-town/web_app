# frozen_string_literal: true

require "test_helper"

class Webhooks::PublishBatchJobTest < ActiveSupport::TestCase
  let(:described_class) { Webhooks::PublishBatchJob }

  describe "#perform" do
    describe "when webhook request responds with 4xx status" do
      it "raises an error" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(config: webhook_config, status: "queued", failed_attempts: 5)
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          created_at: "2025-01-01T12:00:01Z",
          updated_at: "2025-01-01T12:00:11Z"
        )
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          created_at: "2025-01-01T12:00:02Z",
          updated_at: "2025-01-01T12:00:22Z"
        )
        expected_body = [
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:01.000Z",
            "updated_at" => "2025-01-01T12:00:11.000Z"
          },
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:02.000Z",
            "updated_at" => "2025-01-01T12:00:22.000Z"
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "13655a5402705ebf320c612c76555d6cf9f98a35c0a694a6019891f27f3f2b13"
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
        assert_match(/Faraday::BadRequestError/, webhook_batch.metadata["notice"])
      end
    end

    describe "when webhook request responds with 5xx status" do
      it "raises an error" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(config: webhook_config, status: "queued", failed_attempts: 5)
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          created_at: "2025-01-01T12:00:01Z",
          updated_at: "2025-01-01T12:00:11Z"
        )
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          created_at: "2025-01-01T12:00:02Z",
          updated_at: "2025-01-01T12:00:22Z"
        )
        expected_body = [
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:01.000Z",
            "updated_at" => "2025-01-01T12:00:11.000Z"
          },
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:02.000Z",
            "updated_at" => "2025-01-01T12:00:22.000Z"
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "13655a5402705ebf320c612c76555d6cf9f98a35c0a694a6019891f27f3f2b13"
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
        assert_match(/Faraday::ServerError/, webhook_batch.metadata["notice"])
      end
    end

    describe "when webhook request times out" do
      it "raises an error" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(config: webhook_config, status: "queued", failed_attempts: 5)
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          created_at: "2025-01-01T12:00:01Z",
          updated_at: "2025-01-01T12:00:11Z"
        )
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          created_at: "2025-01-01T12:00:02Z",
          updated_at: "2025-01-01T12:00:22Z"
        )
        expected_body = [
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:01.000Z",
            "updated_at" => "2025-01-01T12:00:11.000Z"
          },
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:02.000Z",
            "updated_at" => "2025-01-01T12:00:22.000Z"
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "13655a5402705ebf320c612c76555d6cf9f98a35c0a694a6019891f27f3f2b13"
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
        assert_match(/Faraday::ConnectionFailed/, webhook_batch.metadata["notice"])
      end
    end

    describe "when webhook request failed multiple times" do
      it "raises an error and set status 'failed'" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(config: webhook_config, status: "queued", failed_attempts: 25)
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          created_at: "2025-01-01T12:00:01Z",
          updated_at: "2025-01-01T12:00:11Z"
        )
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          created_at: "2025-01-01T12:00:02Z",
          updated_at: "2025-01-01T12:00:22Z"
        )
        expected_body = [
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "failed_attempts" => 25,
            "created_at" => "2025-01-01T12:00:01.000Z",
            "updated_at" => "2025-01-01T12:00:11.000Z"
          },
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "failed_attempts" => 25,
            "created_at" => "2025-01-01T12:00:02.000Z",
            "updated_at" => "2025-01-01T12:00:22.000Z"
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "30a5a1f2810f62c83e43f6e3373ae776e89107b8dc0955090431f7d6bffde8db"
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
        assert_equal(26, webhook_batch.failed_attempts)
        assert_match(/Faraday::ServerError/, webhook_batch.metadata["notice"])
      end
    end

    describe "when webhook request responds with 2xx status" do
      it "does not raise any errors set status 'delivered'" do
        webhook_config = create_webhook_config(
          method: "POST",
          url: "https://game.company.com/webhook_events",
          secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        )
        webhook_batch = create_webhook_batch(config: webhook_config, status: "queued", failed_attempts: 5)
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
          created_at: "2025-01-01T12:00:01Z",
          updated_at: "2025-01-01T12:00:11Z"
        )
        create_webhook_event(
          config: webhook_config,
          batch: webhook_batch,
          type: "server_vote.created",
          data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
          created_at: "2025-01-01T12:00:02Z",
          updated_at: "2025-01-01T12:00:22Z"
        )
        expected_body = [
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:01.000Z",
            "updated_at" => "2025-01-01T12:00:11.000Z"
          },
          {
            "type" => "server_vote.created",
            "data" => {
              "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
            },
            "failed_attempts" => 5,
            "created_at" => "2025-01-01T12:00:02.000Z",
            "updated_at" => "2025-01-01T12:00:22.000Z"
          }
        ].to_json
        expected_headers = {
          "Content-Type" => "application/json",
          "X-Signature"  => "13655a5402705ebf320c612c76555d6cf9f98a35c0a694a6019891f27f3f2b13"
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
        assert(webhook_batch.metadata["notice"].blank?)
      end

      describe "other config methods" do
        it "works with PUT" do
          webhook_config = create_webhook_config(
            method: "PUT",
            url: "https://game.company.com/webhook_events",
            secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
          )
          webhook_batch = create_webhook_batch(config: webhook_config, status: "queued", failed_attempts: 5)
          create_webhook_event(
            config: webhook_config,
            batch: webhook_batch,
            type: "server_vote.created",
            data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
            created_at: "2025-01-01T12:00:01Z",
            updated_at: "2025-01-01T12:00:11Z"
          )
          create_webhook_event(
            config: webhook_config,
            batch: webhook_batch,
            type: "server_vote.created",
            data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
            created_at: "2025-01-01T12:00:02Z",
            updated_at: "2025-01-01T12:00:22Z"
          )
          expected_body = [
            {
              "type" => "server_vote.created",
              "data" => {
                "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
              },
              "failed_attempts" => 5,
              "created_at" => "2025-01-01T12:00:01.000Z",
              "updated_at" => "2025-01-01T12:00:11.000Z"
            },
            {
              "type" => "server_vote.created",
              "data" => {
                "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
              },
              "failed_attempts" => 5,
              "created_at" => "2025-01-01T12:00:02.000Z",
              "updated_at" => "2025-01-01T12:00:22.000Z"
            }
          ].to_json
          expected_headers = {
            "Content-Type" => "application/json",
            "X-Signature"  => "13655a5402705ebf320c612c76555d6cf9f98a35c0a694a6019891f27f3f2b13"
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
          assert(webhook_batch.metadata["notice"].blank?)
        end

        it "works with PATCH" do
          webhook_config = create_webhook_config(
            method: "PATCH",
            url: "https://game.company.com/webhook_events",
            secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
          )
          webhook_batch = create_webhook_batch(config: webhook_config, status: "queued", failed_attempts: 5)
          create_webhook_event(
            config: webhook_config,
            batch: webhook_batch,
            type: "server_vote.created",
            data: { "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" } },
            created_at: "2025-01-01T12:00:01Z",
            updated_at: "2025-01-01T12:00:11Z"
          )
          create_webhook_event(
            config: webhook_config,
            batch: webhook_batch,
            type: "server_vote.created",
            data: { "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" } },
            created_at: "2025-01-01T12:00:02Z",
            updated_at: "2025-01-01T12:00:22Z"
          )
          expected_body = [
            {
              "type" => "server_vote.created",
              "data" => {
                "server_vote" => { "uuid" => "11111111-1111-1111-1111-111111111111" }
              },
              "failed_attempts" => 5,
              "created_at" => "2025-01-01T12:00:01.000Z",
              "updated_at" => "2025-01-01T12:00:11.000Z"
            },
            {
              "type" => "server_vote.created",
              "data" => {
                "server_vote" => { "uuid" => "22222222-2222-2222-2222-222222222222" }
              },
              "failed_attempts" => 5,
              "created_at" => "2025-01-01T12:00:02.000Z",
              "updated_at" => "2025-01-01T12:00:22.000Z"
            }
          ].to_json
          expected_headers = {
            "Content-Type" => "application/json",
            "X-Signature"  => "13655a5402705ebf320c612c76555d6cf9f98a35c0a694a6019891f27f3f2b13"
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
          assert(webhook_batch.metadata["notice"].blank?)
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
