# frozen_string_literal: true

class PaginationCursor
  HARD_MAX = 500

  DEFAULT_OPTIONS = {
    order: 'desc',

    per_page:              25,
    per_page_max:          100,
    per_page_from_request: false,

    indicator: 'after',

    cursor:        nil,
    cursor_column: :id, # :uuid, :created_at, etc
    cursor_type:   :integer, # :string, :date, :datetime, :decimal, :float

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
    @per_page  = choose_per_page
    @indicator = choose_indicator
    @cursor    = choose_cursor

    @model = relation.klass
    @request_helper = RequestHelper.new(request)

    @cursor, @cursor_id = load_cursor_and_cursor_id
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
    @start_cursor_url ||= build_url({ 'order' => order }, ['indicator', 'cursor'])
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
    @before_cursor_url ||= build_url({ 'order' => order, 'indicator' => 'before', 'cursor' => serialize_cursor(before_cursor) })
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
    @after_cursor_url ||= build_url({ 'order' => order, 'indicator' => 'after', 'cursor' => serialize_cursor(after_cursor) })
  end

  private

  def choose_order
    (request.params['order'].presence || options[:order]).to_s.downcase == 'asc' ? 'asc' : 'desc'
  end

  def choose_per_page
    if options[:per_page_from_request]
      request.params['per_page'].presence || options[:per_page]
    else
      options[:per_page]
    end.to_i.clamp(1, [options[:per_page_max], HARD_MAX].min)
  end

  def choose_indicator
    (request.params['indicator'].presence || options[:indicator]).to_s.downcase == 'before' ? 'before' : 'after'
  end

  def choose_cursor
    value = request.params['cursor'].presence || options[:cursor]

    case value
    when Numeric, Date, Time, DateTime
      value
    when String
      deserialize_cursor(value)
    end
  end

  def load_cursor_and_cursor_id
    return [nil, nil] unless cursor

    case options[:cursor_type]
    when :integer, :date
      @model
        .order(order_condition(options[:cursor_column], cursor))
        .where(where_condition(options[:cursor_column], cursor, true, 1))
        .pick(options[:cursor_column], :id)
    when :datetime, :decimal, :float
      @model
        .order(order_condition(options[:cursor_column], cursor))
        .where(where_condition(options[:cursor_column], cursor, true, 0.000001))
        .pick(options[:cursor_column], :id)
    else
      @model
        .where(options[:cursor_column] => cursor)
        .pick(options[:cursor_column], :id)
    end
  end

  def relation_plus_one
    @relation_plus_one ||= begin
      rel = relation
        .reorder(order_condition(:id, cursor_id))
        .where(where_condition(:id, cursor_id))
        .limit(per_page + 1)
      rel.load
      rel
    end
  end

  def order_condition(column, value)
    if !value || indicator == 'after'
      order == 'desc' ? { column => :desc } : { column => :asc  }
    else
      order == 'desc' ? { column => :asc  } : { column => :desc }
    end
  end

  def where_condition(column, value, inclusive = false, unit = 1)
    return unless value

    backward = inclusive ? (..value)  : (...value)
    forward  = inclusive ? (value...) : ((value + unit)...)

    if indicator == 'after'
      order == 'desc' ? { column => backward } : { column => forward  }
    else
      order == 'desc' ? { column => forward  } : { column => backward }
    end
  end

  def deserialize_cursor(str)
    str = str.delete('^a-zA-Z0-9_:.-')
    return if str.blank?

    case options[:cursor_type]
    when :string   then str
    when :integer  then Integer(str, exception: false)
    when :date     then Date.iso8601(str)
    when :datetime then Time.iso8601(str)
    when :decimal  then BigDecimal(str, exception: false)
    when :float    then Float(str, exception: false)
    end
  rescue TypeError, ArgumentError, Date::Error
    nil
  end

  def serialize_cursor(value)
    return unless value

    case value
    when String then value
    when Date   then value.iso8601
    when Time   then value.iso8601(6)
    else
      value.to_s
    end
  end

  def build_url(params_merge, params_remove = [])
    if options[:per_page_from_request]
      @request_helper.url_with_query(
        params_merge.merge({ 'per_page' => per_page }).compact,
        params_remove - ['per_page']
      )
    else
      @request_helper.url_with_query(
        params_merge.compact,
        params_remove + ['per_page']
      )
    end
  end
end
