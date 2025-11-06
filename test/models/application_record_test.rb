# frozen_string_literal: true

require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  let(:described_class) { ApplicationRecord }

  describe "#move_errors" do
    it "move errors from one attribute to the other" do
      dummy = create_dummy

      dummy.move_errors(:nothing, :nowhere)

      assert_empty(dummy.errors)

      dummy.errors.add(:created_at, :blank, message: "some message", if: true)
      dummy.errors.add(:created_at, :too_short, count: 3)

      assert_equal(2, dummy.errors.where(:created_at).size)

      dummy.move_errors(:created_at, :updated_at)

      assert_equal(0, dummy.errors.where(:created_at).size)
      assert_equal(2, dummy.errors.where(:updated_at).size)

      first_error, second_error = dummy.errors.where(:updated_at)

      assert_equal(:blank, first_error.type)
      assert_equal({ message: "some message", if: true }, first_error.options)

      assert_equal(:too_short, second_error.type)
      assert_equal({ count: 3 }, second_error.options)
    end
  end
end
