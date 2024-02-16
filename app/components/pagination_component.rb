# frozen_string_literal: true

class PaginationComponent < ApplicationComponent
  DEFAULT_OPTIONS = {
    show_prev_page:   true,
    show_next_page:   true,
    show_first_page:  true,
    show_last_page:   true, # This calls pagination's total_count
    show_page_series: true,
    show_total_pages: true, # TODO: This calls pagination's total_count
    show_goto_page:   true, # TODO: implement
  }

  def render?
    @pagination.present?
  end

  def initialize(pagination:, options: {})
    super()

    @pagination = pagination
    @options = DEFAULT_OPTIONS.merge(options)

    @classes = token_list('
      mx-0.5
      btn
      btn btn-secondary
    ')
    @current_classes = token_list('
      mx-0.5
      btn
      btn-secondary--disabled
    ')

    @prev_enabled_classes = token_list('
      mx-0.5
      btn
      btn-secondary
    ')
    @prev_disabled_classes = token_list('
      mx-0.5
      btn
      btn-secondary--disabled
    ')

    @next_enabled_classes = token_list('
      mx-0.5
      btn
      btn-secondary
    ')
    @next_disabled_classes = token_list('
      mx-0.5
      btn
      btn-secondary--disabled
    ')

    @gap_classes = token_list('
      mx-0.5
      btn
      btn-secondary--disabled
    ')
  end

  def generate_page_series
    start_at = @pagination.page - 2
    end_at   = @pagination.page + 2

    if (1..3).cover?(@pagination.page)
      start_at = 2

      end_at =
        if @options[:show_last_page]
          start_at + 4
        else
          start_at + 2
        end
    end

    if @options[:show_last_page]
      if ((@pagination.last_page - 2)..@pagination.last_page).cover?(@pagination.page)
        end_at   = @pagination.last_page - 1
        start_at = end_at - 4
      end
    end

    if start_at <= @pagination.first_page
      start_at = @pagination.first_page + 1
    end

    if @options[:show_last_page]
      if end_at >= @pagination.last_page
        end_at = @pagination.last_page - 1
      end
    else
      if !@pagination.next_page?
        end_at = @pagination.page
      end
    end

    page_series = (start_at..end_at).to_a

    if start_at > @pagination.first_page + 1
      page_series.unshift(nil)
    end

    if @options[:show_last_page]
      if end_at < @pagination.last_page - 1
        page_series.push(nil)
      end
    else
      page_series.push(nil)
    end

    page_series
  end
end
