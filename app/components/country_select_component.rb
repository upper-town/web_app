# frozen_string_literal: true

class CountrySelectComponent < ViewComponent::Base
  attr_reader(
    :form,
    :only_in_use,
    :with_continents,
    :blank_name,
    :selected_value
  )

  def initialize(
    form,
    only_in_use: false,
    with_continents: false,
    blank_name: "All",
    selected_value: nil
  )
    super()

    @form = form
    @only_in_use = only_in_use
    @with_continents = with_continents
    @blank_name = blank_name
    @selected_value = selected_value

    @query = CountrySelectOptionsQuery.new(only_in_use:, with_continents:)
  end

  def blank_option
    [blank_name, nil]
  end

  def options
    @options ||= @query.call
  end
end
