# frozen_string_literal: true

class PaginationCursorComponent < ViewComponent::Base
  DEFAULT_OPTIONS = {
    show_first: true,
    show_goto:  false,

    show_total_pages: false, # This calls pagination's total_count
    show_per_page:    false,
    show_total_count: false, # This calls pagination's total_count

    first_icon: 'First',
    prev_icon:  'Prev',
    next_icon:  'Next',
    go_icon:    'Go',
  }

  attr_reader :pagination_cursor, :options

  def initialize(pagination_cursor, **options)
    super()

    @pagination_cursor = pagination_cursor
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def show_badges?
    show_total_pages? || show_per_page? || show_total_count?
  end

  def show_first?
    options[:show_first]
  end

  def show_goto?
    options[:show_goto]
  end

  def show_total_pages?
    options[:show_total_pages]
  end

  def show_per_page?
    options[:show_per_page]
  end

  def show_total_count?
    options[:show_total_count]
  end

  def first_icon
    options[:first_icon]
  end

  def prev_icon
    options[:prev_icon]
  end

  def next_icon
    options[:next_icon]
  end

  def go_icon
    options[:go_icon]
  end
end
