# frozen_string_literal: true

# == Schema Information
#
# Table name: feature_flags
#
#  id         :bigint           not null, primary key
#  comment    :string           default(""), not null
#  name       :string           not null
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_feature_flags_on_name  (name) UNIQUE
#
class FeatureFlag < ApplicationRecord
  # This is a simple feature flag implementation that reads from the database
  # or from env vars. An env var feature flag takes precedence over a database
  # feature flag of the same name.
  #
  # If you need elaborate logic for your feature flag, consider implementing
  # a Policy object instead.
  #
  # Example of env vars to set a feature flag named "something":
  #
  #   FF_SOMETHING="true"
  #   FF_SOMETHING="false"
  #   FF_SOMETHING="true:user_1,user_2"
  #   FF_SOMETHING="false:user_1,user_2"
  #
  # Where:
  #
  #   FF_
  #     Prefix to all feature flag env var names
  #
  #   true
  #     Indicates the feature flag is enabled
  #
  #   false
  #     Indicates the feature flag is disabled
  #
  #   user_1,user_2
  #     Comma-separated list of Record Feature Flag IDs (ffids) to which the
  #     feature flag applies. See FeatureFlagId.
  #
  # Usage:
  #
  #   FeatureFlag.enabled?(:something)
  #   FeatureFlag.enabled?(:something, user)
  #   FeatureFlag.enabled?(:something, 'user_1')
  #
  ENV_VAR_PREFIX    = 'FF_'
  ENABLED_SEPARATOR = ':'
  FFID_SEPARATOR    = ','

  def self.enabled?(name, record_or_ffid = nil)
    value = fetch_value(StringValueHelper.remove_whitespaces(name.to_s))
    return false unless value

    enabled, ffids = parse_enabled_and_ffids(value)

    if ffids.empty? || ffids.include?(build_ffid(record_or_ffid))
      enabled
    else
      !enabled
    end
  end

  def self.disabled?(...)
    !enabled?(...)
  end

  def self.fetch_value(name)
    return if name.blank?

    if (value = fetch_value_from_env_var(name))
      value
    else
      fetch_value_from_database(name)
    end
  end

  def self.fetch_value_from_env_var(name)
    env_var_name = "#{ENV_VAR_PREFIX}#{name.upcase}"

    ENV.fetch(env_var_name, nil).presence
  end

  def self.fetch_value_from_database(name)
    select(:value).find_by(name: name)&.value
  end

  def self.parse_enabled_and_ffids(value)
    enabled_str, ffids_str = value.split(ENABLED_SEPARATOR, 2)

    [
      StringValueHelper.to_boolean(enabled_str.to_s),
      StringValueHelper.values_list_uniq(ffids_str.to_s, FFID_SEPARATOR)
    ]
  end

  def self.build_ffid(object)
    case object
    when ApplicationRecord
      object.to_ffid
    else
      object.to_s
    end
  end
end
