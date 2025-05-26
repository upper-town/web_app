# frozen_string_literal: true

module StringHelper
  TRUE_STRINGS = ["true", "t", "1", "on", "enabled"]

  extend self

  def to_boolean(str)
    TRUE_STRINGS.include?(remove_whitespaces(str).downcase)
  end

  def remove_whitespaces(str)
    str.gsub(/[[:space:]]/, "")
  end

  def normalize_whitespaces(str)
    str.squish
  end

  def values_list_uniq(str, separator = ",", do_remove_whitespaces = true)
    str.split(separator).map do |part|
      if do_remove_whitespaces
        remove_whitespaces(part)
      else
        normalize_whitespaces(part)
      end
    end
      .compact_blank
      .uniq
  end

  def format_sentence(str)
    period = str.end_with?(".", ",", ";", ":", "!", "?") ? "" : "."

    normalize_whitespaces("#{str}#{period}").capitalize
  end
end
