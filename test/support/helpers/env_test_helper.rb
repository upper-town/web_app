# frozen_string_literal: true

module EnvTestHelper
  def env_with_values(hash)
    env_with_backup_and_restore do
      ENV.update(hash)

      yield
    end
  end

  def env_without_values(*keys)
    env_with_backup_and_restore do
      ENV.delete_if { |key| keys.include?(key) }

      yield
    end
  end

  def env_with_backup_and_restore
    original_env_hash = ENV.to_h

    yield

    ENV.clear
    ENV.update(original_env_hash)
  end
end
