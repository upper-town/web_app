# frozen_string_literal: true

module FeatureFlag
  ENV_VAR_PREFIX = 'FF_'

  TRUE_STR = 'true'
  VALUE_SEPARATOR = ':'
  IDENTIFIERS_SEPARATOR = ','

  # e.g.:
  #   FF_SOMETHING=true
  #   FF_SOMETHING=true:users
  #   FF_SOMETHING=true:users:111,222
  def self.enabled?(name, group_name = nil, identifier = nil)
    true_str, group_name_str, identifiers_str = fetch_env_var_values(name)

    match_true?(true_str) &&
      match_group_name?(group_name_str, group_name) &&
      match_identifier?(identifiers_str, identifier)
  end

  def self.disabled?(name, group_name = nil, identifier = nil)
    !enabled?(name, group_name, identifier)
  end

  # private

  def self.fetch_env_var_values(name)
    env_var_name = "#{ENV_VAR_PREFIX}#{name.to_s.upcase}"

    ENV.fetch(env_var_name, nil).to_s.split(VALUE_SEPARATOR)
  end

  def self.match_true?(true_str)
    true_str == TRUE_STR
  end

  def self.match_group_name?(group_name_str, group_name)
    return true if group_name_str.blank?

    group_name_str == group_name.to_s
  end

  def self.match_identifier?(identifiers_str, identifier)
    return true if identifiers_str.blank?

    identifiers_str.split(IDENTIFIERS_SEPARATOR).include?(identifier.to_s)
  end

  private_class_method(
    :fetch_env_var_values,
    :match_true?,
    :match_group_name?,
    :match_identifier?
  )
end
