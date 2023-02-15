# frozen_string_literal: true

class PagyComponent < ApplicationComponent
  include Pagy::Frontend

  def render?
    @pagy.present? && @pagy_link_proc.present?
  end

  def initialize(pagy:, pagy_link_proc:, hidden_gap: false)
    @pagy = pagy
    @pagy_link_proc = pagy_link_proc
    @hidden_gap = hidden_gap

    @page_nav_classes = token_list('
      my-2
    ')

    @page_prev_enabled_classes = token_list('
      mx-0.5
      btn
      btn-secondary
    ')
    @page_prev_disabled_classes = token_list('
      mx-0.5
      btn
      btn-secondary--disabled
    ')

    @page_next_enabled_classes = token_list('
      mx-0.5
      btn
      btn-secondary
    ')
    @page_next_disabled_classes = token_list('
      mx-0.5
      btn
      btn-secondary--disabled
    ')

    @page_gap_classes =
      if @hidden_gap
        'hidden'
      else
        token_list('
          mx-0.5
          btn
          btn-secondary--disabled
        ')
      end

    @page_classes = token_list('
      mx-0.5
      btn
      btn btn-secondary
    ')
    @page_current_classes = token_list('
      mx-0.5
      btn
      btn-secondary--disabled
    ')
  end
end
