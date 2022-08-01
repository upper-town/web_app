class EmailValidator
  attr_reader :email, :errors

  PATTERN = %r{
    \A
      (?<user>
        [a-z0-9] [a-z0-9._]{,50}
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

  RESERVED_DOMAIN_PATTERNS = [
    /[@.]example\.(com|net|org)/,
    /\.(test|example|invalid|localhost)\z/
  ].freeze

  DISPOSABLE_EMAIL_DOMAINS_LIST = File.readlines(
    Rails.root.join('vendor/disposable_email_domains/list.txt'),
    chomp: true
  )

  def initialize(email)
    @email = email.to_s
    @errors = ['not validated yet']
  end

  def valid?
    @errors.clear

    validate_format
    validate_email_domain

    @errors.empty?
  end

  private

  def validate_format
    unless @email.match?(PATTERN)
      @errors << 'format is not valid'
    end
  end

  def validate_email_domain
    if match_reserved_domain? || match_disposable_email_domains?
      @errors << 'invalid domain'
    end
  end

  def match_reserved_domain?
    RESERVED_DOMAIN_PATTERNS.any? { |pattern| pattern.match?(@email) }
  end

  def match_disposable_email_domains?
    match_data = @email.match(PATTERN)

    match_data.present? && DISPOSABLE_EMAIL_DOMAINS_LIST.include?(match_data[:host])
  end
end
