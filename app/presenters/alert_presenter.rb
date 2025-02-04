# frozen_string_literal: true

class AlertPresenter
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

  attr_reader :variant, :dismissible

  def initialize(variant: DEFAULT_VARIANT, dismissible: true)
    @variant = VARIANTS.include?(variant) ? variant : DEFAULT_VARIANT
    @dismissible = dismissible
  end
end
