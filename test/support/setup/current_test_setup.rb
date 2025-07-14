# frozen_string_literal: true

module CurrentTestSetup
  def setup
    super

    Current.reset
  end
end
