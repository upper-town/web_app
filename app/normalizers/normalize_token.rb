class NormalizeToken
  include Callable

  attr_reader :token

  def initialize(token)
    @token = token
  end

  def call
    return if token.nil?
    return "" if token.blank?

    token.gsub(/[[:space:]]/, "")
  end
end
