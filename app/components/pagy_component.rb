# frozen_string_literal: true

class PagyComponent < ApplicationComponent
  include Pagy::Frontend

  def render?
    @pagy.present? && @pagy_link_proc.present?
  end

  def initialize(pagy:, pagy_link_proc:)
    @pagy = pagy
    @pagy_link_proc = pagy_link_proc

    @page_prev_classes = token_list("
      bg-white
      border
      border-gray-300
      dark:bg-gray-800
      dark:border-gray-700
      dark:hover:bg-gray-700
      dark:hover:text-white
      dark:text-gray-400
      hover:bg-gray-100
      hover:text-gray-700
      leading-tight
      ml-0
      px-3
      py-2
      rounded-l-lg
      text-gray-500
    ")
    @page_prev_disabled_classes = token_list(
      @page_prev_classes,
      "cursor-default"
    )
    @page_next_classes = token_list("
      bg-white
      border
      border-gray-300
      dark:bg-gray-800
      dark:border-gray-700
      dark:hover:bg-gray-700
      dark:hover:text-white
      dark:text-gray-400
      hover:bg-gray-100
      hover:text-gray-700
      leading-tight
      px-3
      py-2
      rounded-r-lg
      text-gray-500
    ")
    @page_next_disabled_classes = token_list(
      @page_next_classes,
      "cursor-default"
    )

    @page_classes = token_list("
      bg-white
      border
      border-gray-300
      dark:bg-gray-800
      dark:border-gray-700
      dark:hover:bg-gray-700
      dark:hover:text-white
      dark:text-gray-400
      hover:bg-gray-100
      hover:text-gray-700
      leading-tight
      px-3
      py-2
      text-gray-500
    ")
    @page_current_classes = token_list("
      bg-blue-50
      border
      border-gray-300
      cursor-default
      dark:bg-gray-700
      dark:border-gray-700
      dark:text-white
      hover:bg-blue-100
      hover:text-blue-700
      px-3
      py-2
      text-blue-600
    ")
  end
end
