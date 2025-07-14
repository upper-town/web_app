# frozen_string_literal: true

require "test_helper"

class Servers::VerifyAccounts::ValidateJsonFileTest < ActiveSupport::TestCase
  let(:described_class) { Servers::VerifyAccounts::ValidateJsonFile }

  it "initializes with errors not empty before calling #valid? or #invalid?" do
    validator = described_class.new(
      {
        "accounts" => [
          "6e781bfd-353a-4e42-9077-6e5ac6cc477c",
          "b8b22a7a-e7d4-4b5b-b0a3-01406e2d5aad"
        ]
      }
    )

    assert_includes(validator.errors, :not_yet_validated)
  end

  describe "#valid? and #invalid?" do
    describe "when data has invalid schema" do
      it "returns false and set errors" do
        [
          nil, " ", 123, {}, [],
          { "accounts" => nil },
          { "accounts" => " " },
          { "accounts" => 123 },
          { "accounts" => {}  },
          { "other"    => []  }
        ].each do |data|
          validator = described_class.new(data)

          assert_not(validator.valid?, "Failed for #{data.inspect}")
          assert(validator.invalid?)
          assert_includes(validator.errors, :json_schema_invalid)
        end
      end
    end

    describe "when data has invalid accounts size" do
      it "returns false and set errors" do
        validator = described_class.new({
          "accounts" => [
            "uuid-01",
            "uuid-02",
            "uuid-03",
            "uuid-04",
            "uuid-05",
            "uuid-06",
            "uuid-07",
            "uuid-08",
            "uuid-09",
            "uuid-10",
            "uuid-11"
          ]
        })

        assert_not(validator.valid?)
        assert(validator.invalid?)
        assert_includes(validator.errors, "must be an array with max size of 10")
      end
    end

    describe "when data has invalid accounts UUIDs format" do
      it "returns false and set errors" do
        validator = described_class.new({
          "accounts" => [
            "uuid-01",
            "ffaf9cfd-72e0-461f-ba12-42c2d080c2c3"
          ]
        })

        assert_not(validator.valid?)
        assert(validator.invalid?)
        assert_includes(validator.errors, "must contain valid Account UUIDs")
      end
    end

    describe "when data has duplicated accounts UUIDs" do
      it "returns false and set errors" do
        validator = described_class.new({
          "accounts" => [
            "ffaf9cfd-72e0-461f-ba12-42c2d080c2c3",
            "ffaf9cfd-72e0-461f-ba12-42c2d080c2c3",
            "2aaeecfc-be65-4c45-9797-1db4a8a9fa5e"
          ]
        })

        assert_not(validator.valid?)
        assert(validator.invalid?)
        assert_includes(validator.errors, "must be an array with non-duplicated Account UUIDs")
      end
    end

    describe "when data has an empty accounts" do
      it "returns true and does not set errors" do
        validator = described_class.new({
          "accounts" => []
        })

        assert(validator.valid?)
        assert_not(validator.invalid?)
        assert_empty(validator.errors)
      end
    end

    describe "when data accounts array has valid UUID strings" do
      it "returns true and does not set errors" do
        validator = described_class.new({
          "accounts" => [
            "9acfa883-2554-4547-9eba-86736e05e036",
            "353b2e46-d352-4ed7-80a5-1486ba3e8d56",
            "d8a577de-1620-4229-878c-75db1fb626b1",
            "241d30ea-6d19-48f5-889d-ff565cdac7e5"
          ]
        })

        assert(validator.valid?)
        assert_not(validator.invalid?)
        assert_empty(validator.errors)
      end
    end
  end
end
