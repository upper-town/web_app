# frozen_string_literal: true

class PaginationUuidCursor
  attr_reader(:cursor, :indicator, :per_page)

  HARD_MIN = 1
  HARD_MAX = 1_000

  DEFAULT_OPTIONS = {
    per_page:              20,
    per_page_from_request: false,
    per_page_min:          5,
    per_page_max:          100,

    cursor:              nil,
    cursor_from_request: true,

    indicator:              :after,
    indicator_from_request: true,

    total_count: nil,
  }.freeze

  def initialize(relation, request, options: {})
    @original_relation = relation
    @request = request
    @options = DEFAULT_OPTIONS.merge(options)

    @cursor    = choose_cursor
    @indicator = choose_indicator
    @per_page  = choose_per_page
  end

  def before_cursor
    # TODO
  end

  def after_cursor
    # TODO
  end

  def before_cursor?
    # TODO
  end

  def after_cursor?
    # TODO
  end

  def before_cursor_url
    if @options[:per_page_from_request]
      build_request_url({ 'before' => before_cursor, 'per_page' => per_page }, ['after'])
    else
      build_request_url({ 'before' => before_cursor }, ['after'])
    end
  end

  def after_cursor_url
    if @options[:per_page_from_request]
      build_request_url({ 'after' => after_cursor, 'per_page' => per_page }, ['before'])
    else
      build_request_url({ 'after' => after_cursor }, ['before'])
    end
  end

  def total_count
    @total_count ||= if @options[:total_count]
      @options[:total_count]
    else
      @original_relation.count
    end
  end

  def total_pages
    @total_pages ||= [
      (total_count.to_f / per_page).ceil,
      HARD_MAX
    ].min
  end

  private

  def choose_cursor
    # TODO
  end

  def choose_indicator
    # TODO
  end

  def choose_per_page
    if @options[:per_page_from_request]
      (@request.params['per_page'].presence || @options[:per_page]).to_i
    else
      @options[:per_page]
    end.clamp(
      [@options[:per_page_min], HARD_MIN].max,
      [@options[:per_page_max], HARD_MAX].min
    )
  end

  def build_request_url(params_merge = {}, params_remove = [])
    params_merge.stringify_keys!
    params_remove.map!(&:to_s)

    parsed_uri = URI.parse(@request.original_url)

    decoded_query = URI.decode_www_form(parsed_uri.query || '').to_h
    decoded_query.merge!(params_merge)
    decoded_query.except!(*params_remove)

    parsed_uri.query = URI.encode_www_form(decoded_query)
    parsed_uri.to_s
  end
end
