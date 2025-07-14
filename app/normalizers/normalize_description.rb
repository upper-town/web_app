# frozen_string_literal: true

class NormalizeDescription
  include Callable

  attr_reader :str

  def initialize(str)
    @str = str
  end

  def call
    return if str.nil?
    return "" if str.blank?

    str.squish
  end
end
