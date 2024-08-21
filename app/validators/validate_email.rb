# frozen_string_literal: true

class ValidateEmail
  PATTERN = %r{
    \A
      (?<user>
        [a-z0-9] [a-z0-9._-]{,50}
      )
      @
      (?<host>
        ([a-z0-9] [a-z0-9-]{,50} \.)?
         [a-z0-9] [a-z0-9-]{,50} \.
        ([a-z0-9] [a-z0-9-]{,50} \.)?
         [a-z0-9] [a-z0-9-]{,50}
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

  DISPOSABLE_EMAIL_DOMAINS_LIST = if Rails.env.test?
    Rails.root.join('vendor/disposable_email_domains/list_test.txt').readlines(chomp: true)
  else
    Rails.root.join('vendor/disposable_email_domains/list.txt').readlines(chomp: true)
  end

  attr_reader :email, :errors

  def initialize(email)
    @email = email.to_s
    @errors = [:not_validated_yet]
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
      errors << :format_is_not_valid
    end
  end

  def validate_email_domain
    if match_reserved_domain? || match_disposable_email_domains?
      errors << :domain_is_not_supported
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
    parts = host.split('.')

    case parts.size
    when 1..3
      parts.any? { |part| RESERVED_NAMES.include?(part) }
    else
      parts.drop(1).any? { |part| RESERVED_NAMES.include?(part) }
    end
  end

  def host_is_disposable_email_domain?(host)
    DISPOSABLE_EMAIL_DOMAINS_LIST.include?(host)
  end
end
