class EnvVarHelper
  def self.with_values(hash)
    with_backup_and_restore do
      ENV.update(hash)

      yield
    end
  end

  def self.without_values(*keys)
    with_backup_and_restore do
      ENV.delete_if { |key| keys.include?(key) }

      yield
    end
  end

  def self.with_backup_and_restore
    original_env_hash = ENV.to_h

    yield

    ENV.clear
    ENV.update(original_env_hash)
  end

  private_class_method :with_backup_and_restore
end
