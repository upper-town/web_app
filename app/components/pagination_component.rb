# frozen_string_literal: true

class PaginationComponent < ViewComponent::Base
  DEFAULT_OPTIONS = {
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

  attr_reader :pagination, :options

  def initialize(pagination, **options)
    super()

    @pagination = pagination
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def show_badges?
    show_page? || show_total_pages? || show_per_page? || show_total_count?
  end

  def show_first?
    options[:show_first]
  end

  def show_last?
    options[:show_last]
  end

  def show_goto?
    options[:show_goto]
  end

  def show_page?
    options[:show_page]
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

  def last_icon
    options[:last_icon]
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
