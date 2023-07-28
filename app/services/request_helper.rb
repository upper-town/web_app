# frozen_string_literal: true

class RequestHelper
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def url_with_query_params(params_merge = {}, params_remove = [])
    params_merge.stringify_keys!
    params_remove.map!(&:to_s)

    parsed_uri = URI.parse(request.original_url)

    decoded_query = URI.decode_www_form(parsed_uri.query || '').to_h
    decoded_query.merge!(params_merge)
    decoded_query.except!(*params_remove)

    parsed_uri.query = URI.encode_www_form(decoded_query)
    parsed_uri.to_s
  end
end
