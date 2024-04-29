# frozen_string_literal: true

class PeriodSelectComponent < ApplicationComponent
  attr_reader(:form, :default_value, :selected_value, :blank_name)

  def initialize(form, default_value: ServerStat::MONTH, selected_value: nil)
    super()

    @form = form
    @default_value = default_value
    @selected_value = selected_value

    @query = PeriodSelectOptionsQuery.new
  end

  def options
    @options ||= @query.call
  end
end
