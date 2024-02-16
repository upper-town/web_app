# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  include Rails.application.routes.url_helpers

  def ==(other)
    super || (
      other.instance_of?(self.class) &&
        other.attributes['id'].present? && attributes['id'].present? &&
        other.id == id
    )
  end
end
