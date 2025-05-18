Date::DATE_FORMATS[:default] = Date::DATE_FORMATS[:iso8601]

class Date
  def to_s
    to_fs(:default)
  end
end
