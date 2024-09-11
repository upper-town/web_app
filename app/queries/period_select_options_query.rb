# frozen_string_literal: true

class PeriodSelectOptionsQuery
  include Callable

  def call
    Periods::PERIOD_OPTIONS
  end
end
