# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaginationCursor do
  describe '#indicator' do
    it 'gets indicator from options' do
      relation = User.order(id: :asc)
      [
        [' ',      false, nil, 'after' ],
        ['before', false, nil, 'before'],
        ['after',  false, nil, 'after'],

        [' ',      true,  nil,      'after' ],
        ['before', true,  nil,      'before'],
        [' ',      true,  nil,      'after' ],
        ['before', true,  nil,      'before'],
        ['before', true,  ' ',      'before'],
        ['after',  true,  '123',    'after'],
        ['after',  true,  'before', 'before'],
      ].each do |indicator, indicator_from_request, request_indicator_param, expected_indicator|
        request = TestRequestHelper.build(params: { 'indicator' => request_indicator_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          indicator: indicator,
          indicator_from_request: indicator_from_request
        )

        expect(pagination_cursor.indicator).to eq(expected_indicator)
      end
    end
  end

  describe '#order' do
    it 'gets order from options' do
      relation = User.order(id: :asc)
      [
        [' ',    false, nil, 'desc' ],
        ['desc', false, nil, 'desc' ],
        ['xxxx', false, nil, 'desc' ],
        ['asc',  false, nil, 'asc'  ],

        [' ',    true,  ' ',    'desc' ],
        [' ',    true,  'xxxx', 'desc' ],
        ['desc', true,  ' ',    'desc' ],
        ['desc', true,  'xxxx', 'desc' ],
        ['desc', true,  'asc',  'asc'  ],
        ['asc',  true,  ' ',    'asc'  ],
      ].each do |order, order_from_request, request_order_param, expected_order|
        request = TestRequestHelper.build(params: { 'order' => request_order_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          order: order,
          order_from_request: order_from_request
        )

        expect(pagination_cursor.order).to eq(expected_order)
      end
    end
  end

  describe '#cursor and #cursor_id' do
    it 'gets cursor from options' do
      _account1 = create(:account, id: 1)
      _account2 = create(:account, id: 2)
      account4  = create(:account, id: 4)
      _account5 = create(:account, id: 5)
      relation  = Account.order(id: :asc)
      [
        [:id, 'desc', 'after',  ' ', false, nil, nil, nil],
        [:id, 'desc', 'before', ' ', false, nil, nil, nil],
        [:id, 'asc',  'after',  ' ', false, nil, nil, nil],
        [:id, 'asc',  'before', ' ', false, nil, nil, nil],

        [:id, 'desc', 'after',  'abcdef', false, nil, nil, nil],
        [:id, 'desc', 'before', 'abcdef', false, nil, nil, nil],
        [:id, 'asc',  'after',  'abcdef', false, nil, nil, nil],
        [:id, 'asc',  'before', 'abcdef', false, nil, nil, nil],

        [:id, 'desc', 'after',  '3', false, nil, 2, 2],
        [:id, 'desc', 'before', '3', false, nil, 4, 4],
        [:id, 'asc',  'after',  '3', false, nil, 4, 4],
        [:id, 'asc',  'before', '3', false, nil, 2, 2],

        [:id, 'desc', 'after',  ' ', true, ' ',            nil, nil ],
        [:id, 'desc', 'after',  '3', true, ' ',            2,   2   ],
        [:id, 'desc', 'after',  ' ', true, 'abcdef',       nil, nil ],
        [:id, 'desc', 'after',  ' ', true, '3',            2,   2   ],
        [:id, 'desc', 'after',  ' ', true, " 3!*[(?'\t\n", 2,   2   ],

        [:uuid, 'desc', 'after',  ' ', false, nil, nil, nil],
        [:uuid, 'desc', 'before', ' ', false, nil, nil, nil],
        [:uuid, 'asc',  'after',  ' ', false, nil, nil, nil],
        [:uuid, 'asc',  'before', ' ', false, nil, nil, nil],

        [:uuid, 'desc', 'after',  'abcdef', false, nil, nil, nil],
        [:uuid, 'desc', 'before', 'abcdef', false, nil, nil, nil],
        [:uuid, 'asc',  'after',  'abcdef', false, nil, nil, nil],
        [:uuid, 'asc',  'before', 'abcdef', false, nil, nil, nil],

        [:uuid, 'desc', 'after',  ' ',           true, ' ',                           nil,           nil],
        [:uuid, 'desc', 'after',  account4.uuid, true, ' ',                           account4.uuid, 4  ],
        [:uuid, 'desc', 'after',  ' ',           true, 'abcdef',                      nil,           nil],
        [:uuid, 'desc', 'after',  ' ',           true, account4.uuid,                 account4.uuid, 4  ],
        [:uuid, 'desc', 'after',  ' ',           true, " #{account4.uuid}!*[(?'\t\n", account4.uuid, 4  ],
      ].each do |cursor_column, order, indicator, cursor, cursor_from_request, request_cursor_param, expected_cursor, expected_cursor_id|
        request = TestRequestHelper.build(params: { 'cursor' => request_cursor_param })
        pagination_cursor = described_class.new(
          relation,
          request,
          cursor_column: cursor_column,
          order: order,
          indicator: indicator,
          cursor: cursor,
          cursor_from_request: cursor_from_request
        )

        expect(pagination_cursor.cursor).to eq(expected_cursor)
        expect(pagination_cursor.cursor_id).to eq(expected_cursor_id)
      end
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

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: '', per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([users[0], users[1], users[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: '', per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([users[0], users[1], users[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[0].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[9].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[2].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([users[0], users[1]])
        expect(pagination_cursor.page_size).to eq(2)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[2].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([users[3], users[4], users[5]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[3].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([users[0], users[1], users[2]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[8].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([users[5], users[6], users[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[8].id, per_page: 3, order: 'asc')
        expect(pagination_cursor.results).to eq([users[9]])
        expect(pagination_cursor.page_size).to eq(1)
      end
    end

    describe 'order desc' do
      it 'takes per_page items from relation for page' do
        users = create_list(:user, 10)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: '', per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([users[9], users[8], users[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: '', per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([users[9], users[8], users[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[0].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[9].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to be_empty
        expect(pagination_cursor.page_size).to eq(0)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[2].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([users[5], users[4], users[3]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[2].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([users[1], users[0]])
        expect(pagination_cursor.page_size).to eq(2)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[6].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([users[9], users[8], users[7]])
        expect(pagination_cursor.page_size).to eq(3)

        pagination_cursor = described_class.new(relation, request, indicator: 'before', cursor: users[8].id, per_page: 3, order: 'desc')
        expect(pagination_cursor.results).to eq([users[9]])
        expect(pagination_cursor.page_size).to eq(1)

        pagination_cursor = described_class.new(relation, request, indicator: 'after', cursor: users[8].id, per_page: 3, order: 'desc')
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

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after&per_page=3')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after&per_page=3')
      end
    end

    describe 'with 1 record' do
      it 'returns accordingly' do
        user = create(:user)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after&per_page=3')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to eq(user.id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{user.id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to eq(user.id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{user.id}&per_page=3")
      end
    end

    describe 'with many records' do
      it 'returns accordingly' do
        users = create_list(:user, 10)
        relation = User.order(id: :asc)
        request = TestRequestHelper.build(url: 'http://test.upper.town/servers')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to eq(users[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{users[2].id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to eq(users[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{users[2].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before')

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before')

        expect(pagination_cursor.after_cursor).to eq(users[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{users[2].id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(true)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to be_nil
        expect(pagination_cursor.has_before_cursor?).to be(false)
        expect(pagination_cursor.before_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=before&per_page=3')

        expect(pagination_cursor.after_cursor).to eq(users[2].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{users[2].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', cursor: users[2].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to eq(users[3].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{users[3].id}")

        expect(pagination_cursor.after_cursor).to eq(users[5].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{users[5].id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', cursor: users[2].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to eq(users[3].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{users[3].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to eq(users[5].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{users[5].id}&per_page=3")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', cursor: users[8].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to eq(users[9].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{users[9].id}")

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'after', cursor: users[8].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to eq(users[9].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{users[9].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to be_nil
        expect(pagination_cursor.has_after_cursor?).to be(false)
        expect(pagination_cursor.after_cursor_url).to eq('http://test.upper.town/servers?order=asc&indicator=after&per_page=3')

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', cursor: users[9].id)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc')

        expect(pagination_cursor.before_cursor).to eq(users[6].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{users[6].id}")

        expect(pagination_cursor.after_cursor).to eq(users[8].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{users[8].id}")

        pagination_cursor = described_class.new(relation, request, order: 'asc', per_page: 3, indicator: 'before', cursor: users[9].id, per_page_from_request: true)

        expect(pagination_cursor.start_cursor).to be_nil
        expect(pagination_cursor.start_cursor?).to be(false)
        expect(pagination_cursor.start_cursor_url).to eq('http://test.upper.town/servers?order=asc&per_page=3')

        expect(pagination_cursor.before_cursor).to eq(users[6].id)
        expect(pagination_cursor.has_before_cursor?).to be(true)
        expect(pagination_cursor.before_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=before&cursor=#{users[6].id}&per_page=3")

        expect(pagination_cursor.after_cursor).to eq(users[8].id)
        expect(pagination_cursor.has_after_cursor?).to be(true)
        expect(pagination_cursor.after_cursor_url).to eq("http://test.upper.town/servers?order=asc&indicator=after&cursor=#{users[8].id}&per_page=3")
      end
    end
  end
end
