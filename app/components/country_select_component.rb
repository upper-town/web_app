# frozen_string_literal: true

class CountrySelectComponent < ViewComponent::Base
  attr_reader(
    :form,
    :only_in_use,
    :default_value,
    :selected_value,
    :blank_name
  )

  def initialize(form, only_in_use: false, default_value: nil, selected_value: nil, blank_name: "All")
    super()

    @form = form
    @only_in_use = only_in_use
    @default_value = default_value
    @selected_value = selected_value
    @blank_name = blank_name

    @query = CountrySelectOptionsQuery.new(only_in_use: only_in_use)
  end

  def blank_option
    [blank_name, nil]
  end

  def popular_options
    @popular_options ||= @query.popular_options
  end

  def other_options
    @other_options ||= @query.other_options
  end
end
