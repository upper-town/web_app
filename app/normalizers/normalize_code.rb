# frozen_string_literal: true

class NormalizeCode
  include Callable

  attr_reader :code

  def initialize(code)
    @code = code
  end

  def call
    return if code.nil?
    return "" if code.blank?

    code.gsub(/[[:space:]]/, "").upcase
  end
end
