# frozen_string_literal: true

require 'support/helpers/env_var_helper'

class RailsEnvHelper
  extend RSpec::Mocks::ExampleMethods

  def self.with_env(env)
    EnvVarHelper.with_values('RAILS_ENV' => env) do
      RSpec::Mocks.with_temporary_scope do
        value = ActiveSupport::StringInquirer.new(env)
        allow(Rails).to receive(:env).and_return(value)

        yield

        expect(Rails).to have_received(:env).at_least(:once)
      end
    end
  end
end
