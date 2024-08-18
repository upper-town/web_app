# frozen_string_literal: true

module FeatureFlagIdModel
  def to_ffid
    "#{self.class.name.underscore}_#{id}"
  end
end
