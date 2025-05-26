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

    @key   = parse_key
    @value = parse_value

    @alert_options = parse_alert_options
    @content       = parse_content
    @html_safe     = parse_html_safe
  end

  def render?
    content.present?
  end

  private

  def parse_key
    key, _ = flash_item
    key = key.to_sym

    case key
    when :alert  then :warning
    when :notice then :success
    else
      key
    end
  end

  def parse_value
    _, value = flash_item

    case value
    when Hash
      value.with_indifferent_access
    when ActiveModel::Errors
      value.full_messages
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
      when Hash
        case value[:content]
        when ActiveModel::Errors
          value.full_messages
        else
          value[:content]
        end
      else
        value
      end
    ).compact_blank
  end

  def parse_html_safe
    case value
    when Hash
      value[:html_safe]
    else
      false
    end
  end
end
