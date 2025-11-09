# frozen_string_literal: true

class RequestHelper
  include ActionView::Helpers::FormTagHelper

  attr_reader :request

  def initialize(request)
    @request = request
  end

  def url_with_query(params_merge = {}, params_remove = [])
    _parsed_query, parsed_uri = parse_and_update_query_and_uri(params_merge, params_remove)

    parsed_uri.to_s
  end

  def parse_and_update_query_and_uri(params_merge = {}, params_remove = [])
    parsed_query, parsed_uri = parse_query_and_uri

    parsed_query
      .merge!(params_merge.stringify_keys)
      .except!(*params_remove.map(&:to_s))

    parsed_uri.query = parsed_query.empty? ? nil : URI.encode_www_form(parsed_query)

    [parsed_query, parsed_uri]
  end

  def parse_query_and_uri
    parsed_uri = URI.parse(request.original_url)
    parsed_query = URI.decode_www_form(parsed_uri.query || "").to_h

    [parsed_query, parsed_uri]
  end

  # rubocop:disable Rails/OutputSafety
  def hidden_fields_for_query(params_merge = {}, params_remove = [])
    parsed_query, _parsed_uri = parse_and_update_query_and_uri(params_merge, params_remove)

    parsed_query.map do |key, value|
      hidden_field_tag(
        ERB::Util.html_escape(key),
        ERB::Util.html_escape(value),
        id: nil
      )
    end.join.html_safe
  end
  # rubocop:enable Rails/OutputSafety

  def app_host_referer?
    return false if request.referer.blank?

    parsed_uri = URI.parse(request.referer)
    return false unless ["http", "https"].include?(parsed_uri.scheme)

    parsed_uri.host == AppUtil.webapp_host
  end
end
