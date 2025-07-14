# frozen_string_literal: true

require "test_helper"

class CaptchaTest < ActiveSupport::TestCase
  let(:described_class) { Captcha }

  # rubocop:disable Rails/OutputSafety
  describe "script_tag" do
    it "returns safe HTML script tag for the captcha" do
      request = build_request
      expected_html = <<~HTML.html_safe
        <script type="text/javascript" nonce="#{request.session.id}">
          function captchaOnload() {
            window.dispatchEvent(new CustomEvent("custom-captcha-onload"));
          }
        </script>
        <script src="https://js.hcaptcha.com/1/api.js?onload=captchaOnload&render=explicit&hl=en" async defer></script>
      HTML

      assert_equal(expected_html, described_class.script_tag(request))
    end
  end

  describe "widget_tag" do
    it "returns safe HTML div tag for the captcha" do
      expected_html = <<~HTML.html_safe
        <div
          class="h-captcha"
          data-sitekey="#{ENV.fetch('H_CAPTCHA_SITE_KEY')}"
          data-theme="dark"
          data-turbo-cache="false"
          data-controller="captcha"
          data-action="custom-captcha-onload@window->captcha#onload"
        ></div>
      HTML

      assert_equal(expected_html, described_class.widget_tag)
    end

    it "accepts theme option" do
      assert_includes(described_class.widget_tag(theme: "light"), 'data-theme="light"')
    end
  end
  # rubocop:enable Rails/OutputSafety

  describe "call" do
    describe "when captcha_response is blank" do
      it "returns failure and does not send request to verify captcha" do
        request = build_request(
          params: { "h-captcha-response" => " " },
          remote_ip: "8.8.8.8"
        )
        captcha_verify_request = stub_captcha_verify_request(
          body: { "response" => " ", "remoteip" => "8.8.8.8" },
          response_status: 200,
          response_body: { "success" => false }
        )

        result = described_class.call(request)
        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Please pass the captcha"))

        assert_not_requested(captcha_verify_request)
      end
    end

    describe "when request to verify captcha times out" do
      it "returns failure" do
        request = build_request(
          params: { "h-captcha-response" => "abcdef123456" },
          remote_ip: "8.8.8.8"
        )
        captcha_verify_request = stub_captcha_verify_request(
          body: { "response" => "abcdef123456", "remoteip" => "8.8.8.8" },
          response_timeout: true
        )

        result = described_class.call(request)

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Connection failed"))

        assert_requested(captcha_verify_request)
      end
    end

    describe "when request to verify captcha responds with 5xx status" do
      it "returns failure" do
        request = build_request(
          params: { "h-captcha-response" => "abcdef123456" },
          remote_ip: "8.8.8.8"
        )
        captcha_verify_request = stub_captcha_verify_request(
          body: { "response" => "abcdef123456", "remoteip" => "8.8.8.8" },
          response_status: 500
        )

        result = described_class.call(request)

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Could not verify captcha. Please try again later"))

        assert_requested(captcha_verify_request)
      end
    end

    describe "when request to verify captcha responds with 4xx status" do
      it "returns failure" do
        request = build_request(
          params: { "h-captcha-response" => "abcdef123456" },
          remote_ip: "8.8.8.8"
        )
        captcha_verify_request = stub_captcha_verify_request(
          body: { "response" => "abcdef123456", "remoteip" => "8.8.8.8" },
          response_status: 400
        )

        result = described_class.call(request)

        assert(result.failure?)
        assert(result.errors.of_kind?(:base, "Could not verify captcha. Please try again later"))

        assert_requested(captcha_verify_request)
      end
    end

    describe "when request to verify captcha responds with 2xx status" do
      it "returns success or failure according to response body" do
        [
          [false, {}],
          [false, { "success" => ""    }],
          [false, { "success" => false }],
          [true,  { "success" => true  }]
        ].each_with_index do |(expected_success, response_body), index|
          request = build_request(
            params: { "h-captcha-response" => "abcdef123456#{index}" },
            remote_ip: "8.8.8.8"
          )
          captcha_verify_request = stub_captcha_verify_request(
            body: { "response" => "abcdef123456#{index}", "remoteip" => "8.8.8.8" },
            response_status: 200,
            response_body:
          )

          result = described_class.call(request)

          if expected_success
            assert(result.success?)
          else
            assert(result.failure?)
            assert(result.errors.of_kind?(:base, "Captcha verification failed"))
          end

          assert_requested(captcha_verify_request)
        end
      end
    end
  end

  def stub_captcha_verify_request(
    body: { "response" => "abcdef123456", "remoteip" => "1.1.1.1" },
    response_status: 200,
    response_headers: { "Content-Type" => "application/json" },
    response_body: { "success" => true },
    response_timeout: false
  )
    request = stub_request(
      :post, "https://hcaptcha.com/siteverify"
    ).with(
      headers: { "Content-Type" => "application/x-www-form-urlencoded" },
      body: {
        "sitekey" => ENV.fetch("H_CAPTCHA_SITE_KEY"),
        "secret" => ENV.fetch("H_CAPTCHA_SECRET_KEY")
      }.merge(body).sort.to_h
    )

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
