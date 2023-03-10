# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def default_title
    WebApp::Site::TITLE
  end
end
