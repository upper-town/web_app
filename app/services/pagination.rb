# frozen_string_literal: true

class Pagination
  HARD_MAX = 500

  DEFAULT_OPTIONS = {
    page:     1,
    page_max: 200,

    per_page:              25,
    per_page_max:          100,
    per_page_from_request: false,

    total_count: nil,
  }

  attr_reader(
    :relation,
    :request,
    :options,
    :page,
    :per_page,
    :offset
  )

  def initialize(relation, request, **options)
    @relation = relation
    @request = request
    @options = DEFAULT_OPTIONS.merge(options.compact)

    @page     = choose_page
    @per_page = choose_per_page
    @offset   = calc_offset

    @request_helper = RequestHelper.new(request)
  end

  def results
    @results ||= relation_plus_one.take(per_page)
  end

  def page_size
    @page_size ||= results.size
  end

  # You can provide total_count via options.
  # When not provided, it will only be computed when
  #   you call it
  #   you call total_pages
  #   you call last_page
  #   you call last_page?
  #   you call last_page_url
  def total_count
    @total_count ||= [options[:total_count] || relation.count, 0].max
  end

  # total_pages depends on total_count
  def total_pages
    @total_pages ||= [
      (total_count.to_f / per_page).ceil, options[:page_max]
    ].min.clamp(1, HARD_MAX)
  end

  # last_page depends on total_count
  def last_page
    total_pages
  end

  # last_page? depends on total_count
  def last_page?
    page >= total_pages
  end

  # last_page_url depends on total_count
  def last_page_url
    page_url(last_page)
  end

  def first_page
    1
  end

  def first_page?
    page <= 1
  end

  def first_page_url
    page_url(first_page)
  end

  def prev_page
    @prev_page ||= [page - 1, 1].max
  end

  def has_prev_page?
    page > 1
  end

  def prev_page_url
    page_url(prev_page)
  end

  def next_page
    @next_page ||= if page_size < per_page || relation_plus_one.size <= per_page
      page
    else
      [page + 1, options[:page_max], HARD_MAX].min
    end
  end

  def has_next_page?
    next_page > page
  end

  def next_page_url
    page_url(next_page)
  end

  def page_url(value)
    if options[:per_page_from_request]
      @request_helper.url_with_query({ 'page' => value, 'per_page' => per_page }.compact)
    else
      @request_helper.url_with_query({ 'page' => value }.compact, ['per_page'])
    end
  end

  private

  def choose_page
    (request.params['page'].presence || options[:page]).to_i.clamp(1, [options[:page_max], HARD_MAX].min)
  end

  def choose_per_page
    if options[:per_page_from_request]
      request.params['per_page'].presence || options[:per_page]
    else
      options[:per_page]
    end.to_i.clamp(1, [options[:per_page_max], HARD_MAX].min)
  end

  def calc_offset
    per_page * (page - 1)
  end

  def relation_plus_one
    @relation_plus_one ||= begin
      rel = relation.offset(offset).limit(per_page + 1)
      rel.load
      rel
    end
  end
end
