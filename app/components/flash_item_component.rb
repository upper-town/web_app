# frozen_string_literal: true

class FlashItemComponent < ViewComponent::Base
  attr_reader(
    :flash_item,
    :key,
    :value,
    :alert_options,
    :content,
    :html_safe
  )

  def initialize(flash_item)
    super()

    @flash_item = flash_item

    @key = parse_key
    @value = parse_value

    @alert_options = parse_alert_options
    @content = parse_content
    @html_safe = parse_html_safe
  end

  private

  def parse_key
    key, _value = flash_item
    key = key.to_sym

    case key
    when :alert  then :warning
    when :notice then :info
    else
      key
    end
  end

  def parse_value
    _key, value = flash_item

    case value
    when Hash
      value.with_indifferent_access
    else
      value
    end
  end

  def parse_alert_options
    case value
    when Hash
      {
        variant: key,
        dismissible: value[:dismissible]
      }
    else
      { variant: key }
    end
  end

  def parse_content
    Array(
      case value
      when Hash then value[:content]
      else
        value
      end
    ).compact_blank
  end

  def parse_html_safe
    case value
    when Hash then value[:html_safe]
    else
      false
    end
  end
end
