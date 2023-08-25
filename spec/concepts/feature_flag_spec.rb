# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/env_var_helper'

RSpec.describe FeatureFlag do
  describe '.enabled? and disabled?' do
    context 'when env var is not defined' do
      it 'returns false for enabled?' do
        expect(described_class.enabled?(:non_existent)).to eq(false)
        expect(described_class.enabled?(:non_existent, 'User111')).to eq(false)
      end

      it 'returns true for disabled?' do
        expect(described_class.disabled?(:non_existent)).to eq(true)
        expect(described_class.disabled?(:non_existent, 'User111')).to eq(true)
      end
    end

    context 'when env var is defined' do
      [
        ['FF_SOMETHING', 'true', :something_else, nil,       false],
        ['FF_SOMETHING', 'true', :something_else, 'User111', false],

        ['FF_SOMETHING', 'true', :something, nil,       true],
        ['FF_SOMETHING', 'true', :something, 'User111', true],

        ['FF_SOMETHING', 'false', :something, nil,       false],
        ['FF_SOMETHING', 'false', :something, 'User111', false],

        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, nil,               false],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, User.new,          false],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, 'User111',         true ],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, User.new(id: 111), true ],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, 'User222',         true ],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, User.new(id: 222), true ],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, 'User333',         false],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, User.new(id: 333), false],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, 'Other999',        true ],
        ['FF_SOMETHING', 'true:User111,User222,Other999', :something, 'Other000',        false],

      ].each do |env_var_name, env_var_value, name, ffid, enabled|
        it "returns #{enabled} for #{env_var_name}=#{env_var_value} and name=#{name.inspect}, ffid=#{ffid.inspect}" do
          EnvVarHelper.with_values(env_var_name => env_var_value) do
            expect(described_class.enabled?(name, ffid)).to eq(enabled)
            expect(described_class.disabled?(name, ffid)).to eq(!enabled)
          end
        end
      end
    end
  end
end
