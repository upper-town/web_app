# frozen_string_literal: true

class SiteUrlValidator
  PATTERN = %r{
    \A
      (?<protocol>
        https?
      )
      ://
      (?<host>
        ([a-z0-9] [a-z0-9-]{,50} \.){,3}
         [a-z0-9] [a-z0-9-]{,50} \.
         [a-z0-9] [a-z0-9-]{,50}/?
      )
    \z
  }xi

  attr_reader :site_url, :errors

  def initialize(site_url)
    @site_url = site_url.to_s
    @errors = [:not_validated_yet]
  end

  def valid?
    errors.clear

    validate_format

    errors.empty?
  end

  def invalid?
    !valid?
  end

  private

  def validate_format
    unless site_url.match?(PATTERN)
      errors << :format_is_not_valid
    end
  end
end
