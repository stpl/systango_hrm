class SystangoHrmLeaveSummaryCurrentYear < SystangoHrmModel

  unloadable
  belongs_to :systango_hrm_leave_account, :primary_key => 'user_id', :foreign_key => 'user_id'
  belongs_to :user
  
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  
end
