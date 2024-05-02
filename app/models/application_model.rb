# frozen_string_literal: true

class ApplicationModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  include ActiveSupport::NumberHelper
  include Rails.application.routes.url_helpers

  def ==(other)
    super || (
      other.instance_of?(self.class) &&
        other.attributes['id'].present? && attributes['id'].present? &&
        other.id == id
    )
  end
end
