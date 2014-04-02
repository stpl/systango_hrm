class SystangoHrmHoliday < SystangoHrmModel
  unloadable
  
  include SystangoHrm::CachedModel

  validates :holiday_date, 
            :presence => {:message => l(:holiday_blank_date_error)},
            :uniqueness => {:message => l(:holiday_same_error)},
            :format => { :with => SystangoHrm::Constants::DATE_FORMAT_REGEX,:message=> l(:proper_date_error_message)}
  validates :holiday_for, :presence => {:message => l(:holiday_reason_blank_error)}

  validate :validate_past_dates
  scope :order_by_holiday_desc, -> { order('holiday_date desc') }

  def validate_past_dates
    return errors.add(:holiday_date, l(:holiday_past_date_error)) if !holiday_date.nil? and holiday_date < Date.today
  end

end
