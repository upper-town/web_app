# frozen_string_literal: true

module Captcha
  BASE_URL    = "https://hcaptcha.com"
  VERIFY_PATH = "/siteverify"

  SITE_KEY   = ENV.fetch("H_CAPTCHA_SITE_KEY")
  SECRET_KEY = ENV.fetch("H_CAPTCHA_SECRET_KEY")

  extend self

  # rubocop:disable Rails/OutputSafety
  def script_tag(request)
    <<~HTML.html_safe
      <script type="text/javascript" nonce="#{request.session.id}">
        function captchaOnload() {
          window.dispatchEvent(new CustomEvent("custom-captcha-onload"));
        }
      </script>
      <script src="https://js.hcaptcha.com/1/api.js?onload=captchaOnload&render=explicit&hl=en" async defer></script>
    HTML
  end

  def widget_tag(theme: "dark")
    <<~HTML.html_safe
      <div
        class="h-captcha"
        data-sitekey="#{SITE_KEY}"
        data-theme="#{theme}"
        data-turbo-cache="false"
        data-controller="captcha"
        data-action="custom-captcha-onload@window->captcha#onload"
      ></div>
    HTML
  end
  # rubocop:enable Rails/OutputSafety

  def call(request)
    captcha_response, remote_ip = extract_values(request)

    if captcha_response.blank?
      return Result.failure("Please pass the captcha")
    end

    begin
      response = send_verify_request(captcha_response, remote_ip)

      if response.body["success"].blank? || !response.body["success"]
        Result.failure("Captcha verification failed")
      else
        Result.success
      end
    rescue Faraday::ClientError, Faraday::ServerError
      Result.failure("Could not verify captcha. Please try again later")
    rescue Faraday::Error
      Result.failure("Connection failed")
    end
  end

  private

  def extract_values(request)
    [
      request.params["h-captcha-response"],
      request.remote_ip
    ]
  end

  def send_verify_request(captcha_response, remote_ip)
    connection = Faraday.new(url: BASE_URL) do |builder|
      builder.request :url_encoded
      builder.response :json
      builder.response :raise_error
    end

    connection.post(VERIFY_PATH) do |request|
      request.body = {
        sitekey:  SITE_KEY,
        secret:   SECRET_KEY,
        response: captcha_response,
        remoteip: remote_ip
      }
    end
  end
end
