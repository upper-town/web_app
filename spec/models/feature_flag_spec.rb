# frozen_string_literal: true

# == Schema Information
#
# Table name: feature_flags
#
#  id                     :bigint           not null, primary key
#  comment                :string           default(""), not null
#  expected_expiration_at :datetime
#  name                   :string           not null
#  value                  :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_feature_flags_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe FeatureFlag do
  describe '.enabled? and .disabled?' do
    context 'when feature flag is not found' do
      it 'returns accordingly' do
        expect(described_class.enabled?(:something)).to eq(false)

        expect(described_class.disabled?(:something))
          .to eq(!described_class.enabled?(:something))
      end
    end

    context 'when env var feature flag exists' do
      it 'returns accordingly from env var feature flag' do
        # env var feature flag takes precedence over this one
        create(:feature_flag, name: 'something', value: 'true')

        EnvVarHelper.with_values('FF_SOMETHING' => 'false') do
          expect(described_class.enabled?(:something)).to eq(false)

          expect(described_class.disabled?(:something))
            .to eq(!described_class.enabled?(:something))
        end
      end

      context 'when disabled for specific records' do
        it 'returns accordingly from env var feature flag' do
          # env var feature flag takes precedence over this one
          create(:feature_flag, name: 'something', value: 'true')
          user = create(:user)

          EnvVarHelper.with_values('FF_SOMETHING' => "false:user_#{user.id}") do
            expect(described_class.enabled?(:something)).to eq(true)
            expect(described_class.enabled?(:something, user)).to eq(false)
            expect(described_class.enabled?(:something, "user_#{user.id}")).to eq(false)

            expect(described_class.disabled?(:something))
              .to eq(!described_class.enabled?(:something))
            expect(described_class.disabled?(:something, user))
              .to eq(!described_class.enabled?(:something, user))
            expect(described_class.disabled?(:something, "user_#{user.id}"))
              .to eq(!described_class.enabled?(:something, "user_#{user.id}"))
          end
        end
      end

      context 'when enabled for specific records' do
        it 'returns accordingly from env var feature flag' do
          # env var feature flag takes precedence over this one
          create(:feature_flag, name: 'something', value: 'false')
          user = create(:user)

          EnvVarHelper.with_values('FF_SOMETHING' => "true:user_#{user.id}") do
            expect(described_class.enabled?(:something)).to eq(false)
            expect(described_class.enabled?(:something, user)).to eq(true)
            expect(described_class.enabled?(:something, "user_#{user.id}")).to eq(true)

            expect(described_class.disabled?(:something))
              .to eq(!described_class.enabled?(:something))
            expect(described_class.disabled?(:something, user))
              .to eq(!described_class.enabled?(:something, user))
            expect(described_class.disabled?(:something, "user_#{user.id}"))
              .to eq(!described_class.enabled?(:something, "user_#{user.id}"))
          end
        end
      end
    end

    context 'when env var feature flag does not exist' do
      it 'returns value from database feature flag' do
        create(:feature_flag, name: 'something', value: 'true')

        expect(described_class.enabled?(:something)).to eq(true)

        expect(described_class.disabled?(:something))
          .to eq(!described_class.enabled?(:something))
      end

      context 'when disabled for specific records' do
        it 'returns accordingly from database feature flag' do
          user = create(:user)
          create(:feature_flag, name: 'something', value: "false:user_#{user.id}")

          expect(described_class.enabled?(:something)).to eq(true)
          expect(described_class.enabled?(:something, user)).to eq(false)
          expect(described_class.enabled?(:something, "user_#{user.id}")).to eq(false)

          expect(described_class.disabled?(:something))
            .to eq(!described_class.enabled?(:something))
          expect(described_class.disabled?(:something, user))
            .to eq(!described_class.enabled?(:something, user))
          expect(described_class.disabled?(:something, "user_#{user.id}"))
            .to eq(!described_class.enabled?(:something, "user_#{user.id}"))
        end
      end

      context 'when enabled for specific records' do
        it 'returns accordingly from database feature flag' do
          user = create(:user)
          create(:feature_flag, name: 'something', value: "true:user_#{user.id}")

          expect(described_class.enabled?(:something)).to eq(false)
          expect(described_class.enabled?(:something, user)).to eq(true)
          expect(described_class.enabled?(:something, "user_#{user.id}")).to eq(true)

          expect(described_class.disabled?(:something))
            .to eq(!described_class.enabled?(:something))
          expect(described_class.disabled?(:something, user))
            .to eq(!described_class.enabled?(:something, user))
          expect(described_class.disabled?(:something, "user_#{user.id}"))
            .to eq(!described_class.enabled?(:something, "user_#{user.id}"))
        end
      end
    end
  end

  describe '.fetch_value' do
    context 'when env var feature flag exists' do
      it 'returns value from env var' do
        create(:feature_flag, name: 'something', value: 'true')

        EnvVarHelper.with_values('FF_SOMETHING' => 'false') do
          expect(described_class.fetch_value('something')).to eq('false')
        end
      end
    end

    context 'when env var feature flag does not exist' do
      it 'returns value from database env var' do
        create(:feature_flag, name: 'something', value: 'true')

        expect(described_class.fetch_value('something')).to eq('true')
      end
    end

    context 'when feature flag is not found' do
      it 'returns nil' do
        expect(described_class.fetch_value('something')).to be_nil
      end
    end
  end

  describe '.fetch_value_from_env_vars' do
    it 'fetches from env vars' do
      name = 'something'

      [
        ['SOMETHING',    'true', nil],
        ['FF_SOMETHING', '',     nil],
        ['FF_SOMETHING', " \n",  nil],

        ['FF_SOMETHING', 'true',     'true'],
        ['FF_SOMETHING', 'anything', 'anything'],
      ].each do |env_var_name, env_var_value, expected_value|
        EnvVarHelper.with_values(env_var_name => env_var_value) do
          returned = described_class.fetch_value_from_env_vars(name)

          expect(returned).to(eq(expected_value), "Failed for #{env_var_name.inspect}")
        end
      end
    end
  end

  describe '.fetch_value_from_database' do
    context 'when record with name exists' do
      it 'returns value from record' do
        feature_flag = create(:feature_flag, name: 'something', value: 'true')

        value = described_class.fetch_value_from_database('something')

        expect(value).to eq(feature_flag.value)
      end
    end

    context 'when record with name does not exist' do
      it 'returns nil' do
        value = described_class.fetch_value_from_database('something')

        expect(value).to be_nil
      end
    end
  end

  describe '.parse_enabled_and_ffids' do
    it 'returns boolean and array' do
      [
        [nil, false, []],

        ['',                     false, []],
        [':',                    false, []],
        [':user_1,user_2',       false, ['user_1', 'user_2']],
        [':user_1,user_1,user_1', false, ['user_1']],

        ['false',               false, []],
        ['false:',              false, []],
        ['false:user_1,user_2', false, ['user_1', 'user_2']],
        ['FALSE:user_1,user_2', false, ['user_1', 'user_2']],

        ['anything',               false, []],
        ['anything:',              false, []],
        ['anything:user_1,user_2', false, ['user_1', 'user_2']],
        ['ANYTHING:user_1,user_2', false, ['user_1', 'user_2']],

        ['true',               true, []],
        ['true:',              true, []],
        ['true:user_1,user_2', true, ['user_1', 'user_2']],
        ['TRUE:user_1,user_2', true, ['user_1', 'user_2']],

        ['enabled:user_1,user_2', true, ['user_1', 'user_2']],
        ['ENABLED:user_1,user_2', true, ['user_1', 'user_2']],

        ['on:user_1,user_2', true, ['user_1', 'user_2']],
        ['ON:user_1,user_2', true, ['user_1', 'user_2']],

        ["\n true : , \nuser_1 , user_ 2 ,,\n,user_1", true, ['user_1', 'user_2']],
      ].each do |value, expected_boolean, expected_array|
        enabled, ffids = described_class.parse_enabled_and_ffids(value)

        expect(enabled).to(eq(expected_boolean), "Failed for #{value.inspect}")
        expect(ffids).to(eq(expected_array), "Failed for #{value.inspect}")
      end
    end
  end

  describe '.build_ffid' do
    context 'when object is an ApplicationRecord' do
      it 'calls #to_ffid on it' do
        user = create(:user)

        ffid = described_class.build_ffid(user)

        expect(ffid).to eq("user_#{user.id}")
      end
    end

    context 'when object is anything else' do
      it 'calls #to_s on it' do
        expect(described_class.build_ffid('user_123')).to eq('user_123')
        expect(described_class.build_ffid(:user_123)).to eq('user_123')
        expect(described_class.build_ffid(123)).to eq('123')
        expect(described_class.build_ffid(nil)).to eq('')
      end
    end
  end
end
