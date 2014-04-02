class SystangoHrmLeaveAccount < SystangoHrmModel
  unloadable
  
  belongs_to :designation, :class_name => "SystangoHrmDesignation", :foreign_key => "current_designation_id", :primary_key => :id
  belongs_to :systango_hrm_compoff
  belongs_to :systango_hrm_teamleads_subordinates
  belongs_to :user
  has_one :leave_summary_current_year, :class_name => "SystangoHrmLeaveSummaryCurrentYear", :foreign_key  => "user_id", :primary_key => "user_id"
  has_many :systango_hrm_employee_leave
  has_many :systango_hrm_designation_histories, through: :user

  validates :date_of_joining, 
            :presence => {:message => l(:date_of_joining_not_valid_error)}, 
            :format => { :with => SystangoHrm::Constants::DATE_FORMAT_REGEX, :message=>l(:proper_date_error_message) }
  validates :remarks, :presence =>{:message=>l(:designation_history_remarks_presence_true_error)}, on: :create
  validate :validate_current_designation, :validate_maternity_leave

  scope :by_user_id_and_maternity_leave, ->(user_id,maternity_leave) { where(user_id: user_id, is_maternity_leave: maternity_leave) }
  scope :by_user_ids, ->(user_ids) { where("user_id in (?)", user_ids) }
  scope :by_maternity_leave, ->(maternity_leave) { where(is_eligible_for_maternity_leave: maternity_leave) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :with_active_user, -> { joins(:user).where('users.status = ?', 1) }
  #We are using remarks here beacuse in observer of leave account we need it to store in designation history.
  attr_accessor :remarks

  def validate_current_designation
    errors.add(:current_designation, l(:designation_not_selected_error)) if (self.systango_hrm_designation_histories.blank? or !self.systango_hrm_designation_histories.last.prev_designation_id.nil?) and current_designation_id.blank?
  end            

  def validate_maternity_leave
    return if self.systango_hrm_designation_histories.blank?
    errors.add(:maternity_leave, l(:maternity_leave_check_box_error)) if(( !self.systango_hrm_designation_histories.last.prev_designation_id.nil?) and !self.is_eligible_for_maternity_leave_changed?)
  end

  def maternity_leave
    is_eligible_for_maternity_leave ? SystangoHrm::Constants::MATERNITY_LEAVE_LIMIT : 0
  end

  def leave_reamianing
    ((self.leave_summary_current_year.leaves_entitled + self.leave_summary_current_year.total_comp_off_provided) -  self.leave_summary_current_year.leaves_taken rescue 0)
  end

end