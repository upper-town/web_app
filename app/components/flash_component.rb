# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  def initialize(flash:)
    super()

    @flash = flash
  end

  def render?
    @flash.any?
  end

  def build_alert_kwargs(flash_item)
    key = parse_key(flash_item)
    value = parse_value(flash_item)

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

  def parse_contents(flash_item)
    value = parse_value(flash_item)

    Array(
      case value
      when Hash then value[:content]
      else value
      end
    ).compact_blank
  end

  def parse_html_safe(flash_item)
    value = parse_value(flash_item)

    case value
    when Hash then value[:html_safe]
    else false
    end
  end

  private

  def parse_key(flash_item)
    key, _value = flash_item
    key = key.to_sym

    case key
    when :alert  then :warning
    when :notice then :info
    else key
    end
  end

  def parse_value(flash_item)
    _key, value = flash_item

    case value
    when Hash
      value.with_indifferent_access
    else
      value
    end
  end
end
