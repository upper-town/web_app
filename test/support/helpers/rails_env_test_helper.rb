# frozen_string_literal: true

module RailsEnvTestHelper
  def rails_with_env(env, assert_stub: true, &)
    env_with_values("RAILS_ENV" => env) do
      rails_env = ActiveSupport::StringInquirer.new(env)
      called = 0

      Rails.stub(:env, -> { called += 1 ; rails_env }, &)

      if assert_stub
        assert(called >= 1, "Expected Rails.env to be called at least once")
      end
    end
  end
end
