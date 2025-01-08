# frozen_string_literal: true

module StringValueHelper
  TRUE_STRINGS = ['true', 't', '1', 'on', 'enabled']

  extend self

  def to_boolean(value)
    TRUE_STRINGS.include?(remove_whitespaces(value).downcase)
  end

  def remove_whitespaces(value)
    value.gsub(/[[:space:]]/, '')
  end

  def normalize_whitespaces(value)
    value.squish
  end

  def values_list_uniq(value, separator = ',', do_remove_whitespaces = true)
    value.split(separator).map do |str|
      if do_remove_whitespaces
        remove_whitespaces(str)
      else
        normalize_whitespaces(str)
      end
    end
      .compact_blank
      .uniq
  end
end
