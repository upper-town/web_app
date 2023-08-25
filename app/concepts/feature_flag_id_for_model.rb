# frozen_string_literal: true

module FeatureFlagIdForModel
  def feature_flag_id
    "#{self.class.name}#{id}"
  end

  alias ffid feature_flag_id
end
