# frozen_string_literal: true

module JsonCookie
  def json_cookie_jar
    Rails.env.production? ? request.cookie_jar.encrypted : request.cookie_jar
  end

  def write_json_cookie(name, object, expires: nil, httponly: true)
    json_cookie_jar[name] = {
      value: object.to_json,
      expires:,
      httponly:,
      secure: Rails.env.production?
    }
  end

  def read_json_cookie(name)
    value = json_cookie_jar[name]
    return {} if value.blank?

    attributes = JSON.parse(value)
    return {} if attributes.blank? || !attributes.is_a?(Hash)

    attributes
  rescue TypeError, JSON::ParserError
    {}
  end

  def delete_json_cookie(name)
    request.cookie_jar.delete(name)
  end
end
