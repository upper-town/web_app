# frozen_string_literal: true

class ValidateSiteUrl
  PATTERN = %r{
    \A
      (?<protocol>
        https?
      )
      ://
      (?<host>
        ([a-z0-9] [a-z0-9-]{,49} \.){,4}
         [a-z0-9] [a-z0-9-]{,49} \.
         [a-z0-9] [a-z0-9-]{,49}/?
      )
    \z
  }xi

  RESERVED_NAMES = %w[
    corp
    domain
    example
    home
    host
    internal
    intranet
    invalid
    lan
    local
    localdomain
    localhost
    onion
    private
    test
  ]

  attr_reader :site_url, :errors

  def initialize(site_url)
    @site_url = site_url.to_s
    @errors = [:not_yet_validated]
  end

  def valid?
    errors.clear

    validate_format
    validate_site_url_domain

    errors.empty?
  end

  def invalid?
    !valid?
  end

  private

  def validate_format
    unless site_url.match?(PATTERN)
      @errors << :format_invalid
    end
  end

  def validate_site_url_domain
    if match_reserved_domain?
      @errors << :domain_not_supported
    end
  end

  def match_reserved_domain?
    match_data = site_url.match(PATTERN)

    match_data.present? && host_has_reserved_name?(match_data[:host])
  end

  def host_has_reserved_name?(host)
    parts = host.split(".")

    parts.last(3).any? { |part| RESERVED_NAMES.include?(part) }
  end
end
