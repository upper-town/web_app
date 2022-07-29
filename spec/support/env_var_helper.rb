class EnvVarHelper
  def self.with_values(hash)
    original_env_hash = backup_and_override(hash)

    yield

    restore(original_env_hash)
  end

  def self.backup_and_override(hash)
    original_env_hash = ENV.to_h
    ENV.update(hash)

    original_env_hash
  end

  def self.restore(original_env_hash)
    ENV.clear
    ENV.update(original_env_hash)
  end

  private_class_method :backup_and_override, :restore
end
