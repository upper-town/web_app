# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/env_var_helper'

RSpec.describe FeatureFlag do
  describe '.enabled? and disabled?' do
    context 'when env var is not defined' do
      it 'returns false for enabled?' do
        expect(described_class.enabled?(:non_existent)).to eq(false)
        expect(described_class.enabled?(:non_existent, 'users')).to eq(false)
        expect(described_class.enabled?(:non_existent, 'users', 111)).to eq(false)
      end

      it 'returns true for disabled?' do
        expect(described_class.disabled?(:non_existent)).to eq(true)
        expect(described_class.disabled?(:non_existent, 'users')).to eq(true)
        expect(described_class.disabled?(:non_existent, 'users', 111)).to eq(true)
      end
    end

    context 'when env var is defined' do
      [
        ['FF_SOMETHING', 'true', :something_else, nil,     nil, false],
        ['FF_SOMETHING', 'true', :something_else, 'users', nil, false],
        ['FF_SOMETHING', 'true', :something_else, 'users', 999, false],

        ['FF_SOMETHING', 'true', :something, nil,     nil, true],
        ['FF_SOMETHING', 'true', :something, 'users', nil, true],
        ['FF_SOMETHING', 'true', :something, 'users', 999, true],

        ['FF_SOMETHING', 'false', :something, nil,     nil, false],
        ['FF_SOMETHING', 'false', :something, 'users', nil, false],
        ['FF_SOMETHING', 'false', :something, 'users', 999, false],

        ['FF_SOMETHING', 'true:users', :something, nil,     nil, false],
        ['FF_SOMETHING', 'true:users', :something, nil,     999, false],
        ['FF_SOMETHING', 'true:users', :something, 'users', nil, true ],
        ['FF_SOMETHING', 'true:users', :something, 'users', 999, true ],

        ['FF_SOMETHING', 'true:users:111,222', :something, nil,     nil, false],
        ['FF_SOMETHING', 'true:users:111,222', :something, nil,     111, false],
        ['FF_SOMETHING', 'true:users:111,222', :something, 'users', nil, false],
        ['FF_SOMETHING', 'true:users:111,222', :something, 'users', 111, true ],
        ['FF_SOMETHING', 'true:users:111,222', :something, 'users', 222, true ],
        ['FF_SOMETHING', 'true:users:111,222', :something, 'users', 999, false],

        ['FF_SOMETHING', 'true::111,222', :something, nil,   nil, false],
        ['FF_SOMETHING', 'true::111,222', :something, nil,   111, true ],
        ['FF_SOMETHING', 'true::111,222', :something, 'any', nil, false],
        ['FF_SOMETHING', 'true::111,222', :something, 'any', 111, true ],
        ['FF_SOMETHING', 'true::111,222', :something, 'any', 222, true ],
        ['FF_SOMETHING', 'true::111,222', :something, 'any', 999, false],

      ].each do |env_var_name, env_var_value, name, group_name, identifier, enabled|
        it "returns #{enabled} for #{env_var_name}=#{env_var_value} and " \
          "name=#{name.inspect}, " \
          "group_name=#{group_name.inspect}, " \
          "identifier=#{identifier.inspect}" do
          EnvVarHelper.with_values(env_var_name => env_var_value) do
            expect(described_class.enabled?(name, group_name, identifier)).to eq(enabled)
            expect(described_class.disabled?(name, group_name, identifier)).to eq(!enabled)
          end
        end
      end
    end
  end
end
