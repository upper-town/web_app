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

          EnvVarHelper.with_values('FF_SOMETHING' => "false:User#{user.id}") do
            expect(described_class.enabled?(:something)).to eq(true)
            expect(described_class.enabled?(:something, user)).to eq(false)
            expect(described_class.enabled?(:something, "User#{user.id}")).to eq(false)

            expect(described_class.disabled?(:something))
              .to eq(!described_class.enabled?(:something))
            expect(described_class.disabled?(:something, user))
              .to eq(!described_class.enabled?(:something, user))
            expect(described_class.disabled?(:something, "User#{user.id}"))
              .to eq(!described_class.enabled?(:something, "User#{user.id}"))
          end
        end
      end

      context 'when enabled for specific records' do
        it 'returns accordingly from env var feature flag' do
          # env var feature flag takes precedence over this one
          create(:feature_flag, name: 'something', value: 'false')
          user = create(:user)

          EnvVarHelper.with_values('FF_SOMETHING' => "true:User#{user.id}") do
            expect(described_class.enabled?(:something)).to eq(false)
            expect(described_class.enabled?(:something, user)).to eq(true)
            expect(described_class.enabled?(:something, "User#{user.id}")).to eq(true)

            expect(described_class.disabled?(:something))
              .to eq(!described_class.enabled?(:something))
            expect(described_class.disabled?(:something, user))
              .to eq(!described_class.enabled?(:something, user))
            expect(described_class.disabled?(:something, "User#{user.id}"))
              .to eq(!described_class.enabled?(:something, "User#{user.id}"))
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
          create(:feature_flag, name: 'something', value: "false:User#{user.id}")

          expect(described_class.enabled?(:something)).to eq(true)
          expect(described_class.enabled?(:something, user)).to eq(false)
          expect(described_class.enabled?(:something, "User#{user.id}")).to eq(false)

          expect(described_class.disabled?(:something))
            .to eq(!described_class.enabled?(:something))
          expect(described_class.disabled?(:something, user))
            .to eq(!described_class.enabled?(:something, user))
          expect(described_class.disabled?(:something, "User#{user.id}"))
            .to eq(!described_class.enabled?(:something, "User#{user.id}"))
        end
      end

      context 'when enabled for specific records' do
        it 'returns accordingly from database feature flag' do
          user = create(:user)
          create(:feature_flag, name: 'something', value: "true:User#{user.id}")

          expect(described_class.enabled?(:something)).to eq(false)
          expect(described_class.enabled?(:something, user)).to eq(true)
          expect(described_class.enabled?(:something, "User#{user.id}")).to eq(true)

          expect(described_class.disabled?(:something))
            .to eq(!described_class.enabled?(:something))
          expect(described_class.disabled?(:something, user))
            .to eq(!described_class.enabled?(:something, user))
          expect(described_class.disabled?(:something, "User#{user.id}"))
            .to eq(!described_class.enabled?(:something, "User#{user.id}"))
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
          value = described_class.fetch_value_from_env_vars(name)

          expect(value).to(
            eq(expected_value),
            "Failed for #{name.inspect}: #{value.inspect} is not equal to #{expected_value.inspect}"
          )
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

        ['',                   false, []],
        [':',                  false, []],
        [':User1,User2',       false, ['User1', 'User2']],
        [':User1,User1,User1', false, ['User1']],

        ['false',             false, []],
        ['false:',            false, []],
        ['false:User1,User2', false, ['User1', 'User2']],
        ['FALSE:User1,User2', false, ['User1', 'User2']],

        ['anything',             false, []],
        ['anything:',            false, []],
        ['anything:User1,User2', false, ['User1', 'User2']],
        ['ANYTHING:User1,User2', false, ['User1', 'User2']],

        ['true',             true, []],
        ['true:',            true, []],
        ['true:User1,User2', true, ['User1', 'User2']],
        ['TRUE:User1,User2', true, ['User1', 'User2']],

        ['enabled:User1,User2', true, ['User1', 'User2']],
        ['ENABLED:User1,User2', true, ['User1', 'User2']],

        ['on:User1,User2', true, ['User1', 'User2']],
        ['ON:User1,User2', true, ['User1', 'User2']],

        ["\n true : , \nUser1 , User 2 ,,\n,User1", true, ['User1', 'User2']],
      ].each do |value, expected_boolean, expected_array|
        enabled, ffids = described_class.parse_enabled_and_ffids(value)

        expect(enabled).to(
          eq(expected_boolean),
          "Failed for #{value.inspect}: #{enabled.inspect} is not equal to #{expected_boolean.inspect}"
        )
        expect(ffids).to(
          eq(expected_array),
          "Failed for #{value.inspect}: #{ffids.inspect} is not equal to #{expected_array.inspect}"
        )
      end
    end
  end

  describe '.build_ffid' do
    context 'when object is an ApplicationRecord' do
      it 'calls #ffid on it' do
        user = create(:user)

        ffid = described_class.build_ffid(user)

        expect(ffid).to eq("User#{user.id}")
      end
    end

    context 'when object is anything else' do
      it 'calls #to_s on it' do
        expect(described_class.build_ffid('User123')).to eq('User123')
        expect(described_class.build_ffid(:User123)).to eq('User123')
        expect(described_class.build_ffid(123)).to eq('123')
        expect(described_class.build_ffid(nil)).to eq('')
      end
    end
  end
end
