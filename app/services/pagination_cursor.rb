# frozen_string_literal: true

class PaginationCursor
  attr_reader(:cursor, :indicator, :per_page, :model)

  HARD_MIN = 1
  HARD_MAX = 500

  DEFAULT_OPTIONS = {
    order: :desc,

    per_page:              20,
    per_page_from_request: false,
    per_page_min:          5,
    per_page_max:          100,

    cursor:              nil,
    cursor_from_request: true,
    cursor_column:       :suuid,

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

    @model = @original_relation.klass
  end

  def cursor_id
    @cursor_id ||=
      if @options[:cursor_column] == :suuid
        model.where_by_suuid(cursor).pick(:id)
      else
        model.where(@options[:cursor_column] => cursor).pick(:id)
      end
  end

  def results
    @results ||= begin
      res = relation_plus_one.take(per_page)
      res.reverse! if indicator == :before
      res
    end
  end

  def start_cursor
    nil
  end

  def start_cursor?
    if !before_cursor? && !after_cursor?
      false
    else
      !before_cursor?
    end
  end

  def start_cursor_url
    if @options[:per_page_from_request]
      build_request_url({ 'per_page' => per_page }, ['before', 'after'])
    else
      build_request_url({}, ['before', 'after'])
    end
  end

  def before_cursor
    @before_cursor ||=
      if cursor_id.nil? || (indicator == :before && relation_plus_one.size <= per_page)
        nil
      else
        results.first&.public_send(@options[:cursor_column])
      end
  end

  def after_cursor
    @after_cursor ||=
      if indicator == :after && relation_plus_one.size <= per_page
        nil
      else
        results.last&.public_send(@options[:cursor_column])
      end
  end

  def before_cursor?
    !before_cursor.nil?
  end

  def after_cursor?
    !after_cursor.nil?
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
    @total_count ||= @options[:total_count] || @original_relation.count
  end

  def total_pages
    @total_pages ||= [
      (total_count.to_f / per_page).ceil,
      HARD_MAX
    ].min
  end

  private

  def choose_cursor
    if @options[:cursor_from_request]
      @request.params['after'].presence || @request.params['before'].presence
    else
      @options[:cursor]
    end
  end

  def choose_indicator
    if @options[:indicator_from_request]
      @request.params['before'].present? ? :before : :after
    else
      @options[:indicator]
    end
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

  def relation_plus_one
    @relation_plus_one ||=
      if cursor_id.nil? && !cursor.nil?
        @original_relation.none
      else
        rel = @original_relation.where(where_condition).order(order_condition).limit(per_page + 1)
        rel.load
        rel
      end
  end

  def where_condition
    return unless cursor_id

    case indicator
    when :after
      @options[:order] == :asc ? "id > #{cursor_id}" : "id < #{cursor_id}"
    when :before
      @options[:order] == :asc ? "id < #{cursor_id}" : "id > #{cursor_id}"
    end
  end

  def order_condition
    case indicator
    when :after
      @options[:order] == :asc ? 'id ASC'  : 'id DESC'
    when :before
      @options[:order] == :asc ? 'id DESC' : 'id ASC'
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
