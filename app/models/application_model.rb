class ApplicationModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  include ActiveSupport::NumberHelper
  include Rails.application.routes.url_helpers

  def ==(other)
    super || equal_id(other) || equal_attributes(other)
  end

  private

  def equal_id(other)
    equal_class(other) &&
      other.attributes["id"].present? && attributes["id"].present? &&
      other.id == id
  end

  def equal_attributes(other)
    equal_class(other) &&
      other.attributes == attributes
  end

  def equal_class(other)
    other.instance_of?(self.class)
  end
end
