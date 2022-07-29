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

  def initialize(email)
    @email = email.to_s
    @errors = ['not validated yet']
  end

  def valid?
    @errors.clear

    validate_format
    validate_denylist

    @errors.empty?
  end

  private

  def validate_format
    unless @email.match?(PATTERN)
      @errors << 'format is not valid'
    end
  end

  def validate_denylist
    # TODO: check if host is not included in a denylist
  end
end
