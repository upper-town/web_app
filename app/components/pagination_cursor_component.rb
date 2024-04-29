# frozen_string_literal: true

class PaginationCursorComponent < ApplicationComponent
  DEFAULT_OPTIONS = {
    show_restart_cursor: true,
    show_total_pages:  true, # TODO: This calls pagination's total_count
  }

  def render?
    @pagination_cursor.present?
  end

  def initialize(pagination_cursor:, options: {})
    super()

    @pagination_cursor = pagination_cursor
    @options = DEFAULT_OPTIONS.merge(options)

    @classes = class_names('
      mx-0.5
      btn
      btn btn-secondary
    ')
    @current_classes = class_names('
      mx-0.5
      btn
      btn-secondary--disabled
    ')

    @prev_enabled_classes = class_names('
      mx-0.5
      btn
      btn-secondary
    ')
    @prev_disabled_classes = class_names('
      mx-0.5
      btn
      btn-secondary--disabled
    ')

    @next_enabled_classes = class_names('
      mx-0.5
      btn
      btn-secondary
    ')
    @next_disabled_classes = class_names('
      mx-0.5
      btn
      btn-secondary--disabled
    ')
  end
end
