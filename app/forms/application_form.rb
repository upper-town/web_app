# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  include Rails.application.routes.url_helpers
end
