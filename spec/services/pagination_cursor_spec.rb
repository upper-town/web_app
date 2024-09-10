# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaginationCursor do
  describe '#indicator' do
    it 'gets indicator from options' do
      relation = User.order(id: :asc)
      [
        [' ',      false, nil, nil, 'after' ],
        ['before', false, nil, nil, 'before'],
        ['after',  false, nil, nil, 'after'],

        [' ',      true,  nil,      nil,   'after' ],
        ['before', true,  nil,      nil,   'before'],
        [' ',      true,  'before', nil,   'after' ],
        ['before', true,  'before', nil,   'before'],
        ['before', true,  'before', ' ',   'before'],
        ['after',  true,  'before', '123', 'before'],
      ].each do |indicator, indicator_from_request, request_indicator_param_key, request_indicator_param_value, expected_indicator|
        request = TestRequestHelper.build(params: { request_indicator_param_key => request_indicator_param_value })
        pagination_cursor = described_class.new(
          relation,
          request,
          indicator: indicator,
          indicator_from_request: indicator_from_request
        )

        expect(pagination_cursor.indicator).to eq(expected_indicator), "Failed for #{indicator.inspect} and #{expected_indicator.inspect}"
      end
    end
  end

  describe '#cursor' do
    it 'gets cursor from options' do
      relation = User.order(id: :asc)
      [
        [' ', false, nil,      nil, '' ],
        ['5', false, nil,      nil, '5'],
        ['5', true,  nil,      nil, '5'],
        ['5', true,  'after',  ' ', '5'],
        ['5', true,  'after',  '7', '7'],
        ['5', true,  'before', '7', '7'],
        ['5', true,  'xxxxxx', '7', '5'],

        [5,               false, nil,      nil,             '5'],
        [" !*[(?'\t\n ",  false, nil,      nil,             '' ],
        [" 5!*[(?'\t\n ", false, nil,      nil,             '5'],
        ['5',             true,  'after',  " 7!*[(?'\t\n ", '7'],
        ['5',             true,  'after',  7,               '7'],
        ['5',             true,  'before', " 7!*[(?'\t\n ", '7'],
        ['5',             true,  'before', 7,               '7'],
      ].each do |cursor, cursor_from_request, request_cursor_param_key, request_cursor_param_value, expected_cursor|
        request = TestRequestHelper.build(params: { request_cursor_param_key => request_cursor_param_value })
        pagination_cursor = described_class.new(
          relation,
          request,
          cursor: cursor,
          cursor_from_request: cursor_from_request
        )

        expect(pagination_cursor.cursor).to eq(expected_cursor), "Failed for #{cursor.inspect} and #{expected_cursor.inspect}"
      end
    end
  end

  describe '#cursor_id' do
    it 'picks record id based on cursor_column and cursor' do
      account = create(:account)
      relation = Account.order(id: :asc)
      request = TestRequestHelper.build

      pagination_cursor = described_class.new(
        relation,
        request,
        cursor_column: :id,
        cursor: account.id
      )
      expect(pagination_cursor.cursor_id).to eq(account.id)

      pagination_cursor = described_class.new(
        relation,
        request,
        cursor_column: :uuid,
        cursor: account.uuid
      )
      expect(pagination_cursor.cursor_id).to eq(account.id)
    end
  end

  describe '#per_page' do
    it 'gets per_page from options, clamps value' do
      relation = User.order(id: :asc)
      [
        [20,   nil, false, nil, 20],
        ['20', nil, false, nil, 20],
        [20,   nil, false, 30,  20],
        [20,   10,  false, nil, 10],
        [20,   nil, true, nil,  20],
        [20,   nil, true, 25,   25],
        [20,   nil, true, '25', 25],
        [20,   10,  true, 25,   10],

        [ 1,   nil, false, nil, 1],
        [ '1', nil, false, nil, 1],
        [ 1,   nil, false, 5,   1],
        [ 1,   nil, true,  nil, 1],
        [ 1,   nil, true,  5,   5],
        [-1,   nil, false, nil, 1],
        ['-1', nil, false, nil, 1],
        [-1,   nil, false, 5,   1],
        [-1,   nil, true,  nil, 1],
        [-1,   nil, true,  5,   5],
        [-1,   nil, true,  '5', 5],

        [501, nil, false, nil,   100],
        [501, nil, false, 300,   100],
        [501, 300, false, nil,   300],
        [501, 300, true,  nil,   300],
        [501, nil, true,  300,   100],
        [501, 300, true,  300,   300],
        [501, 300, true,  '300', 300],

        [501, 1_000, false, nil,   500],
        [501, 1_000, false, 300,   500],
        [501, 1_000, true,  nil,   500],
        [501, 1_000, true,  300,   300],
        [501, 1_000, true,  '300', 300],
      ].each do |per_page, per_page_max, per_page_from_request, request_per_page_param, expected_per_page|
        request = TestRequestHelper.build(params: { 'per_page' => request_per_page_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          per_page: per_page,
          per_page_max: per_page_max,
          per_page_from_request: per_page_from_request
        )

        expect(pagination_cursor.per_page).to eq(expected_per_page), "Failed for #{per_page.inspect} and #{expected_per_page.inspect}"
      end
    end
  end

  describe '#results and #page_size' do
    describe 'order asc' do
      it 'takes per_page items from relation for page' do
        users = create_list(:user, 10)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: '', per_page: 3, order: :asc)
        expect(pagination_cursor.results).to eq([users[0], users[1], users[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: '', per_page: 3, order: :asc)
        expect(pagination_cursor.results).to eq([users[0], users[1], users[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[0].id, per_page: 3, order: :asc)
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[9].id, per_page: 3, order: :asc)
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[2].id, per_page: 3, order: :asc)
        expect(pagination_cursor.results).to eq([users[0], users[1]])
        expect(pagination_cursor.page_size).to eq(2)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[2].id, per_page: 3, order: :asc)
        expect(pagination_cursor.results).to eq([users[3], users[4], users[5]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[3].id, per_page: 3, order: :asc)
        expect(pagination_cursor.results).to eq([users[0], users[1], users[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[8].id, per_page: 3, order: :asc)
        expect(pagination_cursor.results).to eq([users[5], users[6], users[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[8].id, per_page: 3, order: :asc)
        expect(pagination_cursor.results).to eq([users[9]])
        expect(pagination_cursor.page_size).to eq(1)
      end
    end

    describe 'order desc' do
      it 'takes per_page items from relation for page' do
        users = create_list(:user, 10)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: '', per_page: 3, order: :desc)
        expect(pagination_cursor.results).to eq([users[9], users[8], users[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: '', per_page: 3, order: :desc)
        expect(pagination_cursor.results).to eq([users[9], users[8], users[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[0].id, per_page: 3, order: :desc)
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[9].id, per_page: 3, order: :desc)
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[2].id, per_page: 3, order: :desc)
        expect(pagination_cursor.results).to eq([users[5], users[4], users[3]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[2].id, per_page: 3, order: :desc)
        expect(pagination_cursor.results).to eq([users[1], users[0]])
        expect(pagination_cursor.page_size).to eq(2)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[6].id, per_page: 3, order: :desc)
        expect(pagination_cursor.results).to eq([users[9], users[8], users[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[8].id, per_page: 3, order: :desc)
        expect(pagination_cursor.results).to eq([users[9]])
        expect(pagination_cursor.page_size).to eq(1)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[8].id, per_page: 3, order: :desc)
        expect(pagination_cursor.results).to eq([users[7], users[6], users[5]])
        expect(pagination_cursor.page_size).to eq(3)
      end
    end
  end

  describe '#total_count and #total_pages' do
    context 'when it is zero' do
      it 'returns accordingly' do
        create_list(:user, 10)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, total_count: 0, per_page: 3)

        expect(pagination_cursor.total_count).to eq(0)
        expect(pagination_cursor.total_pages).to eq(1)
      end
    end

    context 'when total_count option is given' do
      it 'returns it' do
        create_list(:user, 10)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, total_count: 100, per_page: 3)

        expect(pagination_cursor.total_count).to eq(100)
        expect(pagination_cursor.total_pages).to eq(34)
      end
    end

    context 'when total_count option is not given' do
      it 'returns relation count' do
        create_list(:user, 10)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, total_count: nil, per_page: 3)

        expect(pagination_cursor.total_count).to eq(10)
        expect(pagination_cursor.total_pages).to eq(4)
      end
    end
  end

  describe '#start_cursor, #start_cursor?, #start_cursor_url, #before_cursor, #has_before_cursor?, #before_cursor_url, #after_cursor, #has_after_cursor?, #after_cursor_url' do
    describe 'with 0 records' do
      it 'returns accordingly' do
        relation = User.order(id: :asc)
        request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?per_page=3')
      end
    end

    describe 'with 1 record' do
      it 'returns accordingly' do
        user = create(:user)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.after_cursor).to eq(user.id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{user.id}")

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.after_cursor).to eq(user.id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{user.id}&per_page=3")
      end
    end

    describe 'with many records' do
      it 'returns accordingly' do
        users = create_list(:user, 10)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.after_cursor).to eq(users[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{users[2].id}")

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.after_cursor).to eq(users[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{users[2].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.after_cursor).to eq(users[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{users[2].id}")

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.after_cursor).to eq(users[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{users[2].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after', cursor: users[2].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to eq(users[3].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?before=#{users[3].id}")

        expect(pagination_cursor.after_cursor).to eq(users[5].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{users[5].id}")

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after', cursor: users[2].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to eq(users[3].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?before=#{users[3].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to eq(users[5].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{users[5].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after', cursor: users[8].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to eq(users[9].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?before=#{users[9].id}")

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'after', cursor: users[8].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to eq(users[9].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?before=#{users[9].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'before', cursor: users[9].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers')

        expect(pagination_cursor.before_cursor).to eq(users[6].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?before=#{users[6].id}")

        expect(pagination_cursor.after_cursor).to eq(users[8].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{users[8].id}")

        pagination_cursor = described_class.new(relation, request, order: :asc, per_page: 3, indicator: 'before', cursor: users[9].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?per_page=3')

        expect(pagination_cursor.before_cursor).to eq(users[6].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?before=#{users[6].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to eq(users[8].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?after=#{users[8].id}&per_page=3")
      end
    end
  end
end
