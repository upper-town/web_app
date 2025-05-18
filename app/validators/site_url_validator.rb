class SiteUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_site_url = ValidateSiteUrl.new(value)

    return if validate_site_url.valid?

    validate_site_url.errors.each do |message_or_type|
      record.errors.add(attribute, message_or_type)
    end
  end
end
