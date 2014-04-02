module SystangoHrm

  module Constants
  	MATERNITY_LEAVE = "Maternity Leave"
  	HALF_DAY = "Half Day"
  	FULL_DAY = "Full Day"
  	DATETIME_FORMAT_REGEX= /^([0-9]{4})-([0-1][0-9])-([0-3][0-9])\s([0-1][0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9])\sUTC$/
    DATE_FORMAT_REGEX = /^(19|20)\d\d[\-\/.](0[1-9]|1[012])[\-\/.](0[1-9]|[12][0-9]|3[01])$/
  	STATUS_APPROVED = "Approve"
  	STATUS_UNAPPROVED = "Unapprove"
  	STATUS_PENDING = "pending"
  	STATUS_ALL = "All"
    APPROVED = "Approved"
    UNAPPROVED = "Unapproved"
    PENDING = "Pending"
    NAME_WISE = "name_wise"
    DESIGNATION_WISE = "designation_wise"
    EMPLOYEE_CODE = "Employee Code"
    MATERNITY_LEAVE_LIMIT = 90
    SELF = "Self"
    REFER = "refer"
    NONE = "none"
    CANCEL = "cancel"
    STATUS_ACTIVE = 1
    STATUS_LOCKED = 3
  end
  
end
