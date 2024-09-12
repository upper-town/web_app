# frozen_string_literal: true

class PaginationCursor
  HARD_MAX = 500

  DEFAULT_OPTIONS = {
    order: :desc,

    per_page:              20,
    per_page_max:          100,
    per_page_from_request: false,

    indicator:              'after',
    indicator_from_request: true,

    cursor:              nil,
    cursor_column:       :id,
    cursor_from_request: true,

    total_count: nil,
  }

  attr_reader(
    :relation,
    :request,
    :options,
    :cursor,
    :indicator,
    :per_page
  )

  def initialize(relation, request, **options)
    @relation = relation
    @request = request
    @options = DEFAULT_OPTIONS.merge(options.compact)

    @indicator = choose_indicator
    @cursor    = choose_cursor
    @per_page  = choose_per_page

    @model = relation.klass
    @request_helper = RequestHelper.new(request)
  end

  def cursor_id
    @cursor_id ||= @model.where(options[:cursor_column] => cursor).pick(:id)
  end

  def results
    @results ||= begin
      res = relation_plus_one.take(per_page)
      res.reverse! if cursor_id && indicator != 'after'
      res
    end
  end

  def page_size
    @page_size ||= results.size
  end

  # You can provide total_count via options.
  # When not provided, it will only be computed when
  #   you call it
  #   you call total_pages
  def total_count
    @total_count ||= [options[:total_count] || relation.count, 0].max
  end

  # total_pages depends on total_count
  def total_pages
    @total_pages ||= (total_count.to_f / per_page).ceil.clamp(1, HARD_MAX)
  end

  def start_cursor
    nil
  end

  def start_cursor?
    !has_before_cursor?
  end

  def start_cursor_url
    if options[:per_page_from_request]
      @request_helper.url_with_query({ 'per_page' => per_page }.compact, ['before', 'after'])
    else
      @request_helper.url_with_query({}, ['before', 'after'])
    end
  end

  def before_cursor
    @before_cursor ||=
      if cursor_id.nil? || (indicator != 'after' && relation_plus_one.size <= per_page)
        nil
      else
        results.first&.public_send(options[:cursor_column])
      end
  end

  def has_before_cursor?
    !before_cursor.nil?
  end

  def before_cursor_url
    if options[:per_page_from_request]
      @request_helper.url_with_query({ 'before' => before_cursor, 'per_page' => per_page }.compact, ['after'])
    else
      @request_helper.url_with_query({ 'before' => before_cursor }.compact, ['after'])
    end
  end

  def after_cursor
    @after_cursor ||=
      if indicator == 'after' && relation_plus_one.size <= per_page
        nil
      else
        results.last&.public_send(options[:cursor_column])
      end
  end

  def has_after_cursor?
    !after_cursor.nil?
  end

  def after_cursor_url
    if options[:per_page_from_request]
      @request_helper.url_with_query({ 'after' => after_cursor, 'per_page' => per_page }.compact, ['before'])
    else
      @request_helper.url_with_query({ 'after' => after_cursor }.compact, ['before'])
    end
  end

  private

  def choose_indicator
    if options[:indicator_from_request]
      if request.params['after'].present?
        'after'
      elsif request.params['before'].present?
        'before'
      else
        options[:indicator]
      end
    else
      options[:indicator]
    end.to_s.downcase == 'before' ? 'before' : 'after'
  end

  def choose_cursor
    if options[:cursor_from_request]
      request.params['after'].presence || request.params['before'].presence || options[:cursor]
    else
      options[:cursor]
    end.to_s.delete('^a-zA-Z0-9_-')
  end

  def choose_per_page
    if options[:per_page_from_request]
      request.params['per_page'].presence || options[:per_page]
    else
      options[:per_page]
    end.to_i.clamp(1, [options[:per_page_max], HARD_MAX].min)
  end

  def relation_plus_one
    @relation_plus_one ||= begin
      rel = relation.reorder(order_condition).where(where_condition).limit(per_page + 1)
      rel.load
      rel
    end
  end

  def order_condition
    if !cursor_id || indicator == 'after'
      options[:order] == :asc ? { id: :asc  } : { id: :desc }
    else
      options[:order] == :asc ? { id: :desc } : { id: :asc  }
    end
  end

  def where_condition
    return unless cursor_id

    if indicator == 'after'
      options[:order] == :asc ? { id: (cursor_id + 1)... } : { id: ...cursor_id }
    else
      options[:order] == :asc ? { id: ...cursor_id } : { id: (cursor_id + 1)... }
    end
  end
end
