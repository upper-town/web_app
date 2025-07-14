# frozen_string_literal: true

class ValidateEmail
  PATTERN = %r{
    \A
      (?<user>
        [a-z0-9] [a-z0-9._-]{,49}
      )
      @
      (?<host>
        ([a-z0-9] [a-z0-9-]{,49} \.){,3}
         [a-z0-9] [a-z0-9-]{,49} \.
         [a-z0-9] [a-z0-9-]{,49}
      )
    \z
  }xi

  RESERVED_NAMES = if Rails.env.local?
    %w[
      example
      local
      localhost
    ]
  else
    %w[
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
  end

  DISPOSABLE_EMAIL_DOMAINS_LIST = if Rails.env.local?
    %w[
      zzz.com
    ]
  else
    Rails.root.join("vendor/disposable_email_domains/list.txt").readlines(chomp: true)
  end

  attr_reader :email, :errors

  def initialize(email)
    @email = email.to_s
    @errors = [:not_yet_validated]
  end

  def valid?
    errors.clear

    validate_format
    validate_email_domain

    errors.empty?
  end

  def invalid?
    !valid?
  end

  private

  def validate_format
    unless email.match?(PATTERN)
      @errors << :format_invalid
    end
  end

  def validate_email_domain
    if match_reserved_domain? || match_disposable_email_domains?
      @errors << :domain_not_supported
    end
  end

  def match_reserved_domain?
    match_data = email.match(PATTERN)

    match_data.present? && host_has_reserved_name?(match_data[:host])
  end

  def match_disposable_email_domains?
    match_data = email.match(PATTERN)

    match_data.present? && host_is_disposable_email_domain?(match_data[:host])
  end

  def host_has_reserved_name?(host)
    parts = host.split(".")

    parts.last(3).any? { |part| RESERVED_NAMES.include?(part) }
  end

  def host_is_disposable_email_domain?(host)
    DISPOSABLE_EMAIL_DOMAINS_LIST.include?(host)
  end
end
