# frozen_string_literal: true

WebMock.disable_net_connect!(
  allow: [
    "localhost",
    "127.0.0.1",
    "#{AppUtil.web_app_host}:#{AppUtil.web_app_port}",
    "hcaptcha.com"
  ]
)
