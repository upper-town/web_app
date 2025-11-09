# frozen_string_literal: true

module RequestTestHelper
  def build_request(
    method: "GET",
    url: "http://#{AppUtil.webapp_host}:#{AppUtil.webapp_port}/",
    params: {},
    headers: {},
    env: {},
    remote_ip: "1.1.1.1",
    referer: nil
  )
    request_env = Rack::MockRequest.env_for(
      url,
      {
        "REQUEST_METHOD" => method,
        "REMOTE_ADDR"    => remote_ip,
        "HTTP_REFERER"   => referer
      }.compact
    )
    request_env["HTTP_HOST"] = "#{request_env['SERVER_NAME']}:#{request_env['SERVER_PORT']}"

    request = ActionDispatch::TestRequest.create(request_env)
    request.params.merge!(params)
    request.headers.merge!(headers)
    request.headers.merge!(env)

    request
  end
end
