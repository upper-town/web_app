# frozen_string_literal: true

WebMock.disable_net_connect!(
  allow: [
    "localhost",
    "127.0.0.1",
    "#{web_app_host}:#{web_app_port}",
    "hcaptcha.com"
  ]
)
