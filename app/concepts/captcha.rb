# frozen_string_literal: true

class Captcha
  BASE_URL    = 'https://hcaptcha.com'
  VERIFY_PATH = '/siteverify'

  SITE_KEY   = ENV.fetch('H_CAPTCHA_SITE_KEY')
  SECRET_KEY = ENV.fetch('H_CAPTCHA_SECRET_KEY')

  # rubocop:disable Rails/OutputSafety
  def script_tag
    <<~HTML.html_safe
      <script type="text/javascript">
        function captchaOnload() {
          window.dispatchEvent(new CustomEvent("custom-captcha-onload"));
        }
      </script>
      <script src="https://js.hcaptcha.com/1/api.js?onload=captchaOnload&render=explicit&hl=en" async defer></script>
    HTML
  end

  def widget_tag
    <<~HTML.html_safe
      <div
        class="h-captcha"
        data-sitekey="#{SITE_KEY}"
        data-theme="light"
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
      return Result.failure('Please pass the captcha.')
    end

    http_response = send_verify_request(captcha_response, remote_ip)

    if !http_response.success?
      return Result.failure('Could not verify captcha. Please try again later.')
    end

    if !http_response.body['success']
      return Result.failure('Captcha verification failed.')
    end

    Result.success
  end

  private

  def extract_values(request)
    [
      request.params['h-captcha-response'],
      request.remote_ip
    ]
  end

  def send_verify_request(captcha_response, remote_ip)
    connection = Faraday.new(BASE_URL) do |conn|
      conn.request :url_encoded
      conn.response :json
    end

    connection.post(VERIFY_PATH) do |request|
      request.body = {
        sitekey:  SITE_KEY,
        secret:   SECRET_KEY,
        response: captcha_response,
        remoteip: remote_ip,
      }
    end
  end
end
