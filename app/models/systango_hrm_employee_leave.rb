class SystangoHrmEmployeeLeave < SystangoHrmModel

  unloadable
  include SystangoHrm::SystangoHrmEmployeeLeaveStateMachine  
 
  belongs_to :systango_hrm_leave_account
  has_many :systango_hrm_request_receivers, :foreign_key => 'application_id', :class_name => "SystangoHrmRequestReceiver", dependent: :destroy
  belongs_to :user, :foreign_key => 'user_id', :class_name => "User"
  belongs_to :referred_user, :foreign_key => 'referral_id', :class_name => "User"
  has_one :systango_hrm_subject, :foreign_key => "id" , :primary_key => "subject_id"

  validates :leave_start_date, :presence => {:message => l(:leave_start_date_not_added_error)}, :format => { :with => SystangoHrm::Constants::DATETIME_FORMAT_REGEX, :message=> l(:proper_date_error_message) }
  validates :leave_end_date, :presence => {:message => l(:leave_end_date_not_added_error)}, :format => { :with => SystangoHrm::Constants::DATETIME_FORMAT_REGEX,:message=> l(:proper_date_error_message) }
	validates :subject_id, :presence => {:message => l(:leave_subject_not_selected_error)}
  validates :remark,
            :length => {maximum: 200, :message => l(:leave_remark_length_exceded_error)},
	          :presence => {:message => l(:leave_remark_not_added_error)}

	validate  :validate_date_and_time, :validate_ml_leave

	scope :by_status, ->(status) { where(status: status) }
  scope :by_date, ->(start_date, end_date) { where(:leave_start_date => start_date.to_date..(end_date.to_date+1.day)) }
  scope :by_user_id_or_referral_id, ->(user_id) { where("(user_id = ? and referral_id is null) or referral_id = ?", user_id,  user_id) }
  scope :by_user_ids_or_referral_ids, ->(user_ids) { where("(user_id in (?) and referral_id is null) or referral_id in (?)", user_ids, user_ids) }
  scope :by_user_and_referral_id, ->(user_id,referral_id) { where(user_id: user_id,referral_id: referral_id) }
  scope :by_referral_id, ->(r_id) { where(referral_id: r_id) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :by_date_and_status, ->(holiday_date, status) { where("Date(leave_start_date) <= Date(?) AND Date(leave_end_date) >= Date(?) AND status=?", holiday_date, holiday_date, status) }
  scope :by_user_id_and_maternity_leave, ->(user_id, maternity_leave) { where(user_id: user_id, is_maternity_leave: maternity_leave ) }
  scope :leaves_in_next_5_and_1_days, ->{ where("Date(leave_start_date) IN (?) ", [(5.days.since.to_date), (1.days.since.to_date)]) }
  scope :order_by_created_desc, -> {order("created_at desc")}

  def validate_date_and_time
    #Returing because no need to fire other validations
    return errors.add(:date, l(:proper_date_error_message)) unless (leave_start_date.to_date rescue false) and (leave_end_date.to_date rescue false)
    errors.add(:date, l(:leave_apply_improper_dates_error)) if leave_end_date.to_date < leave_start_date.to_date
    if is_half_day
      errors.add(:half_day_date, l(:leave_half_day_date_error)) if leave_end_date.to_date != leave_start_date.to_date
      errors.add(:half_day_time, l(:leave_half_day_time_error)) if leave_end_date.to_time < leave_start_date.to_time
      errors.add(:half_day_and_maternity_leave, l(:leave_maternity_and_half_day_applied_together_error)) if is_maternity_leave
    end
    return if User.current.admin_user?
    errors.add(:date, l(:previous_date_leaves_error)) if (leave_start_date.to_date < Date.today) or (leave_end_date.to_date < Date.today)
  end

	def validate_ml_leave
    return unless is_maternity_leave and !leave_end_date.nil? and !leave_end_date.nil?
		applied = self.class.by_user_id_and_maternity_leave(self.applied_user.id, true)
    errors.add(:maternity_leave_already_applied, l(:leave_double_maternity_apply_error)) if !applied.blank? and (applied.last.status != SystangoHrm::Constants::CANCEL) and (applied.last.status != (SystangoHrm::Constants::UNAPPROVED).downcase) and (applied.last.id != self.id)
	  errors.add(:maternity_leave_days, l(:leave_improper_days_for_maternity_error)) if ((leave_end_date.to_date - leave_start_date.to_date) + 1).to_i > SystangoHrm::Constants::MATERNITY_LEAVE_LIMIT
	  errors.add(:maternity_leave_referred, l(:maternity_leave_cant_be_referred_error)) unless referral_id.blank?
	end

  def leave_duration
		return if self.is_maternity_leave
    return (self.class.date_falls_on_weekend_or_holiday?(self.leave_start_date.to_date) ? 0.0 : 0.5) if self.is_half_day

    (self.leave_start_date.to_date..self.leave_end_date.to_date).inject(0) do |duration,date|
      duration+=1 unless(self.class.date_falls_on_weekend_or_holiday?(date)) 
      duration
    end
  end

  def leave_type
    return SystangoHrm::Constants::MATERNITY_LEAVE if self.is_maternity_leave
		self.is_half_day ? SystangoHrm::Constants::HALF_DAY : SystangoHrm::Constants::FULL_DAY
  end

  def applied_user
    self.referral_id.blank? ? self.user : self.referred_user
  end


  class << self
    def date_falls_on_weekend_or_holiday?(date)
      (date_falls_on_weekend?(date) || date_falls_on_holiday?(date)) rescue false
    end

    def date_falls_on_weekend?(date)
      (date.wday == 0 || date.wday == 6) rescue false
    end

    def date_falls_on_holiday?(date)
      SystangoHrmHoliday.all_as_array.map(&:holiday_date).include?(date) rescue false
    end

    def leave_report_admin(status, start_date, end_date, report_type, user_id, designation_id)
		  report = self
		  report = report.by_status(status.downcase) if status != SystangoHrm::Constants::STATUS_ALL
		  report = report.by_date(start_date, end_date) unless start_date.blank? and end_date.blank?
		  report = report.by_user_id_or_referral_id(user_id) if report_type == SystangoHrm::Constants::NAME_WISE and !user_id.blank?
		  if report_type == SystangoHrm::Constants::DESIGNATION_WISE and !designation_id.blank?
        designation_detail = SystangoHrmDesignation.find(designation_id) rescue nil
			  report = report.by_user_ids_or_referral_ids(designation_detail.leave_accounts.map(&:user_id))
		  end
		  report
    end

    ["approved", "unapproved", "pending"].each do |status|
      define_method "#{status}_leaves" do
        User.remove_leaves_of_locked_users(self.by_status(status))
      end
    end

    def leave_report_all
      #select status wise leaves of active users
      return pending_leaves, approved_leaves, unapproved_leaves 
    end

  end  

end
