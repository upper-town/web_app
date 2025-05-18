Time::DATE_FORMATS[:default] = Time::DATE_FORMATS[:iso8601]

class Time
  def to_s
    to_fs(:default)
  end
end

module ActiveSupport
  class TimeWithZone
    def to_s
      to_fs(:default)
    end
  end
end
