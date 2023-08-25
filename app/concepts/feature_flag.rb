# frozen_string_literal: true

# This is a simple feature flag implementation that reads from an env var.
# If you need elaborate logic for your feature flag, consider implementing a
# Policy object instead.
#
# Example of env vars to set a feature flag named "something":
#
#   FF_SOMETHING=true
#   FF_SOMETHING=true:User111,User222,Other999
#
# Where:
#
#   FF_
#     Prefix to all feature flag env var names
#
#   true
#     Indicates the feature flag is enabled
#
#   User111,User222,Other999
#     Comma-separated list of record ffids to which the feature flag is enabled
#     See FeatureFlagIdForModel
#
# Usage:
#
#   FeatureFlag.enabled?(:something)
#   FeatureFlag.enabled?(:something, user)
#   FeatureFlag.enabled?(:something, 'User111')
#
module FeatureFlag
  ENV_VAR_PREFIX  = 'FF_'
  TRUE_STR        = 'true'
  VALUE_SEPARATOR = ':'
  FFID_SEPARATOR  = ','

  def self.enabled?(name, record_or_ffid = nil)
    true_str, ffids_str = fetch_env_var_values(name)

    match_true?(true_str) && match_ffid?(ffids_str, record_or_ffid)
  end

  def self.disabled?(*args)
    !enabled?(*args)
  end

  # private

  def self.fetch_env_var_values(name)
    env_var_name = "#{ENV_VAR_PREFIX}#{name.to_s.upcase}"

    ENV.fetch(env_var_name, nil).to_s.split(VALUE_SEPARATOR)
  end

  def self.match_true?(true_str)
    true_str == TRUE_STR
  end

  def self.match_ffid?(ffids_str, record_or_ffid)
    return true if ffids_str.blank?

    ffids_str.split(FFID_SEPARATOR).include?(ffid_str(record_or_ffid))
  end

  def self.ffid_str(object)
    if object.is_a?(ApplicationRecord)
      object.ffid
    else
      object.to_s
    end
  end

  private_class_method(
    :fetch_env_var_values,
    :match_true?,
    :match_ffid?,
    :ffid_str
  )
end
