# frozen_string_literal: true

class NormalizeNameKey
  include Callable

  attr_reader :str

  def initialize(str)
    @str = str
  end

  def call
    return if str.nil?
    return "" if str.blank?

    str
      .downcase
      .squish
      .tr(" ", "_")
      .squeeze("_")
      .delete("^a-z0-9_")
  end
end
