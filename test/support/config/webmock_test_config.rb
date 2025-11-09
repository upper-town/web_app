# frozen_string_literal: true

WebMock.disable_net_connect!(
  allow: [
    "localhost",
    "127.0.0.1",
    "#{AppUtil.webapp_host}:#{AppUtil.webapp_port}",
    "hcaptcha.com"
  ]
)
