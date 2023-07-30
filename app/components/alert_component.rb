# frozen_string_literal: true

class AlertComponent < ApplicationComponent
  DEFAULT_VARIANT = :info
  VARIANTS = [
    :primary,
    :secondary,
    :success,
    :danger,
    :warning,
    :info,
    :light,
    :dark,
  ]

  def initialize(variant: DEFAULT_VARIANT, dismissible: true)
    @variant = VARIANTS.include?(variant) ? variant : DEFAULT_VARIANT
    @dismissible = dismissible
  end

  def render?
    content.present?
  end
end
