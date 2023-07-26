# frozen_string_literal: true

class Pagination
  attr_reader(:page, :per_page, :offset)

  HARD_MIN = 1
  HARD_MAX = 1_000

  DEFAULT_OPTIONS = {
    page:              1,
    page_from_request: true,
    page_max:          200,

    per_page:              20,
    per_page_from_request: false,
    per_page_min:          5,
    per_page_max:          100,

    total_count: nil,
  }.freeze

  def initialize(relation, request, options: {})
    @original_relation = relation
    @request = request
    @options = DEFAULT_OPTIONS.merge(options)

    @page     = choose_page
    @per_page = choose_per_page
    @offset   = calc_offset
  end

  def results
    @results ||= relation_plus_one.take(per_page)
  end

  def page_size
    @page_size ||= results.size
  end

  def prev_page
    @prev_page ||= [page - 1, HARD_MIN].max
  end

  def next_page
    @next_page ||= if page_size < per_page || relation_plus_one.size <= per_page
      page
    else
      [page + 1, @options[:page_max], HARD_MAX].min
    end
  end

  def prev_page?
    page > 1
  end

  def next_page?
    next_page > page
  end

  def prev_page_url
    page_url(prev_page)
  end

  def next_page_url
    page_url(next_page)
  end

  def first_page
    1
  end

  def last_page
    total_pages
  end

  def first_page?
    page <= 1
  end

  def last_page?
    page >= total_pages
  end

  def first_page_url
    page_url(first_page)
  end

  def last_page_url
    page_url(last_page)
  end

  def page_url(value)
    if @options[:per_page_from_request]
      build_request_url({ 'page' => value, 'per_page' => per_page })
    else
      build_request_url({ 'page' => value })
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
      @options[:page_max],
      HARD_MAX
    ].min
  end

  private

  def choose_page
    if @options[:page_from_request]
      (@request.params['page'].presence || @options[:page]).to_i
    else
      @options[:page]
    end.clamp(
      HARD_MIN,
      [@options[:page_max], HARD_MAX].min
    )
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

  def calc_offset
    per_page * (page - 1)
  end

  def relation_plus_one
    @relation_plus_one ||= begin
      rel = @original_relation.offset(offset).limit(per_page + 1)
      rel.load
      rel
    end
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
