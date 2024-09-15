# frozen_string_literal: true

class PaginationCursor
  HARD_MAX = 500

  DEFAULT_OPTIONS = {
    order: 'desc',
    order_from_request: true,

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
    :order,
    :indicator,
    :cursor,
    :cursor_id,
    :per_page
  )

  def initialize(relation, request, **options)
    @relation = relation
    @request = request
    @options = DEFAULT_OPTIONS.merge(options.compact)

    @order     = choose_order
    @indicator = choose_indicator
    @per_page  = choose_per_page

    @model = relation.klass
    @request_helper = RequestHelper.new(request)

    @cursor, @cursor_id = choose_cursor_and_load_cursor_id
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
      @request_helper.url_with_query({ 'order' => order, 'per_page' => per_page }.compact, ['indicator', 'cursor'])
    else
      @request_helper.url_with_query({ 'order' => order }, ['indicator', 'cursor', 'per_page'])
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
      @request_helper.url_with_query({ 'order' => order, 'indicator' => 'before', 'cursor' => before_cursor, 'per_page' => per_page }.compact)
    else
      @request_helper.url_with_query({ 'order' => order, 'indicator' => 'before', 'cursor' => before_cursor }.compact, ['per_page'])
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
      @request_helper.url_with_query({ 'order' => order, 'indicator' => 'after', 'cursor' => after_cursor, 'per_page' => per_page }.compact)
    else
      @request_helper.url_with_query({ 'order' => order, 'indicator' => 'after', 'cursor' => after_cursor }.compact, ['per_page'])
    end
  end

  private

  def choose_order
    if options[:order_from_request]
      request.params['order'].presence || options[:order]
    else
      options[:order]
    end.to_s.downcase == 'asc' ? 'asc' : 'desc'
  end

  def choose_indicator
    if options[:indicator_from_request]
      request.params['indicator'].presence || options[:indicator]
    else
      options[:indicator]
    end.to_s.downcase == 'before' ? 'before' : 'after'
  end

  def choose_cursor_and_load_cursor_id
    given_cursor =
      if options[:cursor_from_request]
        request.params['cursor'].presence || options[:cursor]
      else
        options[:cursor]
      end.to_s.delete('^a-zA-Z0-9_:.-').presence

    if options[:cursor_column] == :id && (given_cursor = Integer(given_cursor, exception: false))
      @model.order(order_condition(given_cursor)).where(where_condition(given_cursor, true)).pick(:id, :id)
    else
      @model.where(options[:cursor_column] => given_cursor).pick(options[:cursor_column], :id)
    end
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
      rel = relation.reorder(order_condition(cursor_id)).where(where_condition(cursor_id)).limit(per_page + 1)
      rel.load
      rel
    end
  end

  def order_condition(id)
    if !id || indicator == 'after'
      order == 'desc' ? { id: :desc } : { id: :asc  }
    else
      order == 'desc' ? { id: :asc  } : { id: :desc }
    end
  end

  def where_condition(id, inclusive = false)
    return unless id

    backward = inclusive ? (..id)  : (...id)
    forward  = inclusive ? (id...) : ((id + 1)...)

    if indicator == 'after'
      order == 'desc' ? { id: backward } : { id: forward  }
    else
      order == 'desc' ? { id: forward  } : { id: backward }
    end
  end
end
