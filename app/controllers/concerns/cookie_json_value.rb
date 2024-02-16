# frozen_string_literal: true

module CookieJsonValue
  def write_cookie_json_value(name, model, expires: nil, httponly: true, encrypted: true)
    cookie_jar = encrypted ? request.cookie_jar.encrypted : request.cookie_jar

    cookie_jar[name] = { value: model.to_json, expires: expires, httponly: httponly }
  end

  def parse_cookie_json_value(name, encrypted: true)
    cookie_jar = encrypted ? request.cookie_jar.encrypted : request.cookie_jar

    value = cookie_jar[name]
    return {} if value.blank?

    parsed_value = JSON.parse(value)
    return {} if parsed_value.blank? || !parsed_value.is_a?(Hash)

    parsed_value
  rescue TypeError, JSON::ParserError
    {}
  end
end
