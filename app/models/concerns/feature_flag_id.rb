# frozen_string_literal: true

module FeatureFlagId
  def to_ffid
    "#{self.class.name.underscore}_#{id}"
  end
end
