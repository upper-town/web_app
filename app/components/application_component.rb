# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  def content?
    content.present?
  end
end
