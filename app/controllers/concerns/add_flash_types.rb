# frozen_string_literal: true

module AddFlashTypes
  extend ActiveSupport::Concern

  included do
    add_flash_types(
      :success,
      :primary,
      :secondary,
      :success,
      :danger,
      :warning,
      :info,
      :light,
      :dark
    )
  end
end
