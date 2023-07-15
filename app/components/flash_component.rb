# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  def initialize(flash:)
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
        scheme: key,
        subject: value[:subject],
        dismissible: value[:dismissible],
        **(value[:options] || {})
      }.compact
    else
      {
        scheme: key
      }
    end
  end

  def get_alert_content(flash_item)
    value = parse_value(flash_item)

    case value
    when Hash
      value[:content]
    else
      value
    end
  end

  def build_alert_link_to_args(flash_item)
    value = parse_value(flash_item)

    case value
    when Hash
      value[:link_to] || []
    else
      []
    end
  end

  private

  def parse_key(flash_item)
    key, _value = flash_item
    key = key.to_sym

    case key
    when :alert  then :danger
    when :notice then :success
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
