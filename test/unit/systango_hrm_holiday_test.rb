require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmHolidayTest < ActiveSupport::TestCase

  def test_validate_past_dates
    holiday = SystangoHrmHoliday.new
    holiday.holiday_date = "2014-01-01"
    holiday.holiday_for = "New Year"
    assert_equal false, holiday.valid?
    assert_equal true, holiday.errors.has_key?(:holiday_date)
  end
end
