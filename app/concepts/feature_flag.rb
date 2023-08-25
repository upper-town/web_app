# frozen_string_literal: true

# This is a simple feature flag implementation that reads from an env var.
# If you need complex logic for your feature flag, consider implementing a
# Policy object instead.
module FeatureFlag
  ENV_VAR_PREFIX  = 'FF_'
  TRUE_STR        = 'true'
  VALUE_SEPARATOR = ':'
  FFID_SEPARATOR  = ','

  # e.g.:
  #   FF_SOMETHING=true
  #   FF_SOMETHING=true:User111,User222,Other999
  def self.enabled?(name, ffid = nil)
    true_str, ffids_str = fetch_env_var_values(name)

    match_true?(true_str) && match_ffid?(ffids_str, ffid)
  end

  def self.disabled?(name, ffid = nil)
    !enabled?(name, ffid)
  end

  # private

  def self.fetch_env_var_values(name)
    env_var_name = "#{ENV_VAR_PREFIX}#{name.to_s.upcase}"

    ENV.fetch(env_var_name, nil).to_s.split(VALUE_SEPARATOR)
  end

  def self.match_true?(true_str)
    true_str == TRUE_STR
  end

  def self.match_ffid?(ffids_str, ffid)
    return true if ffids_str.blank?

    ffids_str.split(FFID_SEPARATOR).include?(ffid.to_s)
  end

  private_class_method(
    :fetch_env_var_values,
    :match_true?,
    :match_ffid?
  )
end
