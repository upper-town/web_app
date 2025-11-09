# frozen_string_literal: true

class CorsHeadersMiddleware
  OPTIONS_PATHS = ["*", "/"]
  ALLOW_METHODS = "HEAD, OPTIONS, GET, POST, PUT, PATCH, DELETE"
  MAX_AGE       = "7200"

  attr_reader :allow_origin

  def initialize(app)
    @app = app

    @allow_origin = AppUtil.webapp_host
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.options? && OPTIONS_PATHS.include?(request.path)
      response = Rack::Response.new

      response.set_header("Access-Control-Allow-Origin",  allow_origin)
      response.set_header("Access-Control-Allow-Methods", ALLOW_METHODS)
      response.set_header("Access-Control-Max-Age",       MAX_AGE)

      response.finish
    else
      status, headers, body = @app.call(request.env)

      headers["Access-Control-Allow-Origin"]  = allow_origin
      headers["Access-Control-Allow-Methods"] = ALLOW_METHODS
      headers["Access-Control-Max-Age"]       = MAX_AGE

      [status, headers, body]
    end
  end
end

Rails.application.config.middleware.insert_after(
  ActionDispatch::HostAuthorization,
  CorsHeadersMiddleware
)
