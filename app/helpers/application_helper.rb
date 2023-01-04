# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def default_title
    'Web App'
  end
end
