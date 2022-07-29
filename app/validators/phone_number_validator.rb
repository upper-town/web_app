class PhoneNumberValidator
  attr_reader :phone_number, :errors

  def initialize(phone_number)
    @phone_number = phone_number.to_s
    @errors = ['not validated yet']
  end

  def valid?
    @errors.clear

    validate_possible

    @errors.empty?
  end

  def validate_possible
    unless Phonelib.parse(@phone_number).possible?
      @errors << 'not valid'
    end
  end
end
