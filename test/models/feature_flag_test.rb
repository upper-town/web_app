# frozen_string_literal: true

require "test_helper"

class FeatureFlagTest < ActiveSupport::TestCase
  let(:described_class) { FeatureFlag }

  describe "normalizations" do
    it "normalizes name" do
      feature_flag = create_feature_flag(name: "\n\t Some  feature \n")

      assert_equal("some_feature", feature_flag.name)
    end

    it "normalizes value" do
      feature_flag = create_feature_flag(value: "\n\t True : User_1, User_2 \n")

      assert_equal("true:user_1,user_2", feature_flag.value)
    end

    it "normalizes comment" do
      feature_flag = create_feature_flag(comment: "\n\t Some  comment \n")

      assert_equal("Some comment", feature_flag.comment)
    end
  end

  describe ".enabled? and .disabled?" do
    describe "when feature flag is not found" do
      it "returns accordingly" do
        assert_not(described_class.enabled?(:something))

        assert_equal(
          !described_class.enabled?(:something),
          described_class.disabled?(:something)
        )
      end
    end

    describe "when env var feature flag exists" do
      it "returns accordingly from env var feature flag" do
        # env var feature flag takes precedence over this one
        create_feature_flag(name: "something", value: "true")

        env_with_values("FF_SOMETHING" => "false") do
          assert_not(described_class.enabled?(:something))

          assert_equal(
            !described_class.enabled?(:something),
            described_class.disabled?(:something)
          )
        end
      end

      describe "when disabled for specific records" do
        it "returns accordingly from env var feature flag" do
          # env var feature flag takes precedence over this one
          create_feature_flag(name: "something", value: "true")
          user = create_user

          env_with_values("FF_SOMETHING" => "false:user_#{user.id}") do
            assert(described_class.enabled?(:something))
            assert_not(described_class.enabled?(:something, user))
            assert_not(described_class.enabled?(:something, "user_#{user.id}"))

            assert_equal(
              described_class.disabled?(:something),
              !described_class.enabled?(:something)
            )
            assert_equal(
              !described_class.enabled?(:something, user),
              described_class.disabled?(:something, user)
            )
            assert_equal(
              !described_class.enabled?(:something, "user_#{user.id}"),
              described_class.disabled?(:something, "user_#{user.id}")
            )
          end
        end
      end

      describe "when enabled for specific records" do
        it "returns accordingly from env var feature flag" do
          # env var feature flag takes precedence over this one
          create_feature_flag(name: "something", value: "false")
          user = create_user

          env_with_values("FF_SOMETHING" => "true:user_#{user.id}") do
            assert_not(described_class.enabled?(:something))
            assert(described_class.enabled?(:something, user))
            assert(described_class.enabled?(:something, "user_#{user.id}"))

            assert_equal(
              !described_class.enabled?(:something),
              described_class.disabled?(:something)
            )
            assert_equal(
              !described_class.enabled?(:something, user),
              described_class.disabled?(:something, user)
            )
            assert_equal(
              !described_class.enabled?(:something, "user_#{user.id}"),
              described_class.disabled?(:something, "user_#{user.id}")
            )
          end
        end
      end
    end

    describe "when env var feature flag does not exist" do
      it "returns value from database feature flag" do
        create_feature_flag(name: "something", value: "true")

        assert(described_class.enabled?(:something))

        assert_equal(
          !described_class.enabled?(:something),
          described_class.disabled?(:something)
        )
      end

      describe "when disabled for specific records" do
        it "returns accordingly from database feature flag" do
          user = create_user
          create_feature_flag(name: "something", value: "false:user_#{user.id}")

          assert(described_class.enabled?(:something))
          assert_not(described_class.enabled?(:something, user))
          assert_not(described_class.enabled?(:something, "user_#{user.id}"))

          assert_equal(
            !described_class.enabled?(:something),
            described_class.disabled?(:something)
          )
          assert_equal(
            !described_class.enabled?(:something, user),
            described_class.disabled?(:something, user)
          )
          assert_equal(
            !described_class.enabled?(:something, "user_#{user.id}"),
            described_class.disabled?(:something, "user_#{user.id}")
          )
        end
      end

      describe "when enabled for specific records" do
        it "returns accordingly from database feature flag" do
          user = create_user
          create_feature_flag(name: "something", value: "true:user_#{user.id}")

          assert_not(described_class.enabled?(:something))
          assert(described_class.enabled?(:something, user))
          assert(described_class.enabled?(:something, "user_#{user.id}"))

          assert_equal(
            !described_class.enabled?(:something),
            described_class.disabled?(:something)
          )
          assert_equal(
            !described_class.enabled?(:something, user),
            described_class.disabled?(:something, user)
          )
          assert_equal(
            !described_class.enabled?(:something, "user_#{user.id}"),
            described_class.disabled?(:something, "user_#{user.id}")
          )
        end
      end
    end
  end

  describe ".fetch_value" do
    describe "when env var feature flag exists" do
      it "returns value from env var" do
        create_feature_flag(name: "something", value: "true")

        env_with_values("FF_SOMETHING" => "false") do
          assert_equal("false", described_class.fetch_value("something"))
        end
      end
    end

    describe "when env var feature flag does not exist" do
      it "returns value from database env var" do
        create_feature_flag(name: "something", value: "true")

        assert_equal("true", described_class.fetch_value("something"))
      end
    end

    describe "when feature flag is not found" do
      it "returns nil" do
        assert_nil(described_class.fetch_value("something"))
      end
    end

    describe "when feature flag name is blank" do
      it "returns nil" do
        env_with_values("FF_" => "true") do
          assert_nil(described_class.fetch_value(""))
        end
      end
    end
  end

  describe ".fetch_value_from_env_var" do
    it "fetches from env vars" do
      name = "something"

      [
        ["SOMETHING",    "true", nil],
        ["FF_SOMETHING", "",     nil],
        ["FF_SOMETHING", " \n",  nil],

        ["FF_SOMETHING", "true",     "true"],
        ["FF_SOMETHING", "anything", "anything"]
      ].each do |env_var_name, env_var_value, expected_value|
        env_with_values(env_var_name => env_var_value) do
          returned = described_class.fetch_value_from_env_var(name)

          assert(
            expected_value == returned,
            "Failed for #{env_var_name.inspect}"
          )
        end
      end
    end
  end

  describe ".fetch_value_from_database" do
    describe "when record with name exists" do
      it "returns value from record" do
        feature_flag = create_feature_flag(name: "something", value: "true")

        value = described_class.fetch_value_from_database("something")

        assert_equal(feature_flag.value, value)
      end
    end

    describe "when record with name does not exist" do
      it "returns nil" do
        value = described_class.fetch_value_from_database("something")

        assert_nil(value)
      end
    end
  end

  describe ".parse_enabled_and_ffids" do
    it "returns boolean and array" do
      [
        ["",                     false, []],
        [":",                    false, []],
        [":user_1,user_2",       false, ["user_1", "user_2"]],
        [":user_1,user_1,user_1", false, ["user_1"]],

        ["false",               false, []],
        ["false:",              false, []],
        ["false:user_1,user_2", false, ["user_1", "user_2"]],
        ["FALSE:user_1,user_2", false, ["user_1", "user_2"]],

        ["anything",               false, []],
        ["anything:",              false, []],
        ["anything:user_1,user_2", false, ["user_1", "user_2"]],
        ["ANYTHING:user_1,user_2", false, ["user_1", "user_2"]],

        ["true",               true, []],
        ["true:",              true, []],
        ["true:user_1,user_2", true, ["user_1", "user_2"]],
        ["TRUE:user_1,user_2", true, ["user_1", "user_2"]],

        ["enabled:user_1,user_2", true, ["user_1", "user_2"]],
        ["ENABLED:user_1,user_2", true, ["user_1", "user_2"]],

        ["on:user_1,user_2", true, ["user_1", "user_2"]],
        ["ON:user_1,user_2", true, ["user_1", "user_2"]],

        ["\n true : , \nuser_1 , user_ 2 ,,\n,user_1", true, ["user_1", "user_2"]]
      ].each do |value, expected_boolean, expected_array|
        enabled, ffids = described_class.parse_enabled_and_ffids(value)

        assert_equal(
          expected_boolean,
          enabled,
          "Failed for #{value.inspect}"
        )
        assert_equal(
          expected_array,
          ffids,
          "Failed for #{value.inspect}"
        )
      end
    end
  end

  describe ".build_ffid" do
    describe "when object is an ApplicationRecord" do
      it "calls #to_ffid on it" do
        user = create_user

        ffid = described_class.build_ffid(user)

        assert_equal("user_#{user.id}", ffid)
      end
    end

    describe "when object is anything else" do
      it "calls #to_s on it" do
        assert_equal("user_123", described_class.build_ffid("user_123"))
        assert_equal("user_123", described_class.build_ffid(:user_123))
        assert_equal("123", described_class.build_ffid(123))
        assert_equal("", described_class.build_ffid(nil))
      end
    end
  end
end
