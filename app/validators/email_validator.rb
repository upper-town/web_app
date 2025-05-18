class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_email = ValidateEmail.new(value)

    return if validate_email.valid?

    validate_email.errors.each do |message_or_type|
      record.errors.add(attribute, message_or_type)
    end
  end
end
