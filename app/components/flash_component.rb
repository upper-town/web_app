# frozen_string_literal: true

class FlashComponent < ApplicationComponent
  def initialize(flash:)
    @flash = flash
  end

  def render?
    @flash.any?
  end

  def build_alert_kwargs(flash_item)
    key, value = flash_item
    key = rails_flash_keys_map(key.to_sym)

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
    _key, value = flash_item

    case value
    when Hash
      value[:content]
    else
      value
    end
  end

  def build_alert_link_to_args(flash_item)
    _key, value = flash_item

    case value
    when Hash
      value[:link_to] || []
    else
      []
    end
  end

  private

  def rails_flash_keys_map(key)
    case key
    when :alert  then :danger
    when :notice then :success
    else key
    end
  end
end
