class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    validate_phone_number = ValidatePhoneNumber.new(value)

    return if validate_phone_number.valid?

    validate_phone_number.errors.each do |message_or_type|
      record.errors.add(attribute, message_or_type)
    end
  end
end
