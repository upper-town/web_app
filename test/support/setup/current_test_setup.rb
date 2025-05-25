# frozen_string_literal: true

module CurrentTestSetup
  def setup
    Current.reset

    super
  end
end
