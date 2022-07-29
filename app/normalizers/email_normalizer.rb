class EmailNormalizer
  def initialize(email)
    @email = email.to_s
  end

  def call
    @email.gsub(/[[:space:]]/, '').downcase
  end
end
