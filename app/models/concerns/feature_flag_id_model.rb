# frozen_string_literal: true

module FeatureFlagIdModel
  def feature_flag_id
    "#{self.class.name}#{id}"
  end

  alias ffid feature_flag_id
end
