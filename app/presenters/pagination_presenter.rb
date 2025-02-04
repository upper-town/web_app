# frozen_string_literal: true

class PaginationPresenter < SimpleDelegator
  DEFAULT_DISPLAY_OPTIONS = {
    show_first: true,
    show_last:  false, # This calls pagination's total_count
    show_goto:  true,

    show_page:        false,
    show_total_pages: false, # This calls pagination's total_count
    show_per_page:    false,
    show_total_count: false, # This calls pagination's total_count

    first_icon: 'First',
    last_icon:  'Last',
    prev_icon:  'Prev',
    next_icon:  'Next',
    go_icon:    'Go',
  }

  attr_reader :display_options

  def initialize(pagination, **display_options)
    super(pagination)

    @display_options = DEFAULT_DISPLAY_OPTIONS.merge(display_options)
  end

  def show_badges?
    show_page? || show_total_pages? || show_per_page? || show_total_count?
  end

  def show_first?
    display_options[:show_first]
  end

  def show_last?
    display_options[:show_last]
  end

  def show_goto?
    display_options[:show_goto]
  end

  def show_page?
    display_options[:show_page]
  end

  def show_total_pages?
    display_options[:show_total_pages]
  end

  def show_per_page?
    display_options[:show_per_page]
  end

  def show_total_count?
    display_options[:show_total_count]
  end

  def first_icon
    display_options[:first_icon]
  end

  def last_icon
    display_options[:last_icon]
  end

  def prev_icon
    display_options[:prev_icon]
  end

  def next_icon
    display_options[:next_icon]
  end

  def go_icon
    display_options[:go_icon]
  end
end
