class SystangoHrmEmployeeLeavesController < SystangoHrmController
  unloadable
  before_filter :find_or_initialize_employee_leave
  # Don't change order of filters. it is chained.
  before_filter :check_leave_account_is_created, :fetch_teamleads_subordinates, only: [:new, :create, :edit, :update]
  before_filter :leave_application_details, only: [:new, :create, :edit, :update, :application, :accepted, :unapproved, :pending, :manage_request, :update_leave_status]
  before_filter :leave_application_instance, only: [:new, :create, :manage_request, :edit, :update]
  before_filter :authorize_to_view_application, only: [:application,:update_leave_status]
  before_filter :initialize_employee_leave, only: :update
  before_filter :validate_leave_type, only: [:create, :update]
  
  def new
	  @employee_leave = SystangoHrmEmployeeLeave.new
	  render :template => "systango_hrm_employee_leaves/create_update_leaves"
	end

	def create
   	@employee_leave = SystangoHrmEmployeeLeave.new(params[:systango_hrm_employee_leave].merge!(user_id: User.current.id))
   	@employee_leave.referral_id = params[:systango_hrm_employee_leave][:referral_id] if (params[:apply][:leave] == (SystangoHrm::Constants::REFER))
		if @employee_leave.valid?
			@teamlead_users = SystangoHrmTeamleadsSubordinates.unlocked_teamleads_for(SystangoHrmTeamleadsSubordinates.by_subordinate_user_id(params[:systango_hrm_employee_leave][:referral_id]).to_a) if params[:apply][:leave] == (SystangoHrm::Constants::REFER)
			# calling private method for fetching admin, hr and teamlead ids
			tl_admin_hr_ids.each {|tl_admin_hr_id| @employee_leave.systango_hrm_request_receivers << SystangoHrmRequestReceiver.new(receiver_id: tl_admin_hr_id) }
			if @employee_leave.save
				flash[:notice] = l(:leave_applied_success_notice)
				redirect_to_corresponding_path
			else
				render 'create_update_leaves'
			end
		else
			render 'create_update_leaves'
		end
	end
	
	def edit
  	@employee_leave = SystangoHrmEmployeeLeave.find(params[:id])
  	render :template => "systango_hrm_employee_leaves/create_update_leaves"
	end
	
	def update
		if @employee_leave.save
			#To create new Request Receivers
			request_receivers_entry_for_update(@employee_leave,tl_admin_hr_ids)
			send_leave_updated_notification(@employee_leave, tl_admin_hr_ids, (params[:receiver_id][:id] rescue nil), @previous_leave_record) unless date_and_subject_both_updated?(@employee_leave, @previous_leave_record)
  		flash[:notice] = l(:leave_update_success_notice)
  		redirect_to_corresponding_path
		else
			render 'create_update_leaves'
		end
	end

	def show
	end

	def update_leave_status
	  employee_leave = SystangoHrmEmployeeLeave.find(params[:id])
    #TODO :: Why is this variable named as request_changed_by_user ?? What does it signify? [Palash] : Its show which user is changing status of leave application.
		@request_changed_by_user = SystangoHrmRequestReceiver.by_application_and_receiver_id(params[:id], User.current.id).first
		if params[:cancel]
		  employee_leave.cancel!
		else
		  unapprove_leave = (params[:unapprove] == SystangoHrm::Constants::STATUS_UNAPPROVED)
  		@request_changed_by_user.update_leave_status(unapprove_leave, params[:systango_hrm_employee_leave][:comment])
		 	render 'application' and return if @request_changed_by_user.errors.any?
		end
		flash[:notice] = l(:leave_status_change_notice)
		redirect_to application_systango_hrm_employee_leafe_path(employee_leave)
	end

  ["approved" , "unapproved","pending"].each do |status|
    define_method status do
      @leave_status = status
      @all_leaves = SystangoHrmRequestReceiver.request_by_user_and_type(User.current, @leave_status).paginate(:page => params[:page], :per_page => 10) rescue nil
      render 'more_leaves'
    end
  end

	def application
	end

	def manage_request
	  @pending_leaves = (SystangoHrmRequestReceiver.request_by_user_and_type(User.current, SystangoHrm::Constants::STATUS_PENDING))
	  @approved_leaves = (SystangoHrmRequestReceiver.request_by_user_and_type(User.current, SystangoHrm::Constants::APPROVED))
	  @unapproved_leaves = (SystangoHrmRequestReceiver.request_by_user_and_type(User.current, SystangoHrm::Constants::UNAPPROVED))
	  render 'manage_request'
	end

private

  #[ Lakhan ]: kept below def because we do not get reciever params in observer.
  def send_leave_updated_notification(employee_leave, tl_admin_hr_ids, receivers =[], previous_leave_record = nil)
		tl_admin_hr_mails = User.get_email_for_users((tl_admin_hr_ids - receivers.map(&:to_i)))
		#TODO:: Why are we sending previous_leave_record.attributes ? #[Palash] : Because we have to send email to old leave thread that leave has been update.
    SystangoHrmMailer.delay.notify_all_of_leave_updation(tl_admin_hr_mails, previous_leave_record.attributes, employee_leave) 
  end

	def tl_admin_hr_ids
		tl_admin_hr_ids = @teamlead_users.map(&:id) + User.admin_users.map(&:id)
		if params[:apply][:leave] == (SystangoHrm::Constants::SELF).downcase and (@users_with_hr_permission.include?(User.current.id))
			tl_admin_hr_ids -= [User.current.id] 
		elsif params[:apply][:leave] == SystangoHrm::Constants::REFER 
			#[Palash]: If HR leave is reffered then in request recievers entry of HR is also there because User.admin_user find HR.
			tl_admin_hr_ids -= [@employee_leave.referral_id]  if (@users_with_hr_permission.include?(@employee_leave.referral_id))
			tl_admin_hr_ids << User.current.id
		end
		tl_admin_hr_ids += (params[:receiver_id][:id][1..-1].map(&:to_i) rescue [])
		tl_admin_hr_ids.uniq rescue []
	end
  
  def redirect_to_corresponding_path
  	redirect_to new_systango_hrm_employee_leafe_path and return if params[:continue]
    redirect_to leaves_manage_path and return if (params[:apply][:leave] == (SystangoHrm::Constants::REFER) and params[:view])
    redirect_to report_self_path
  end
  
  def initialize_employee_leave
    @previous_leave_record = SystangoHrmEmployeeLeave.find(params[:id])
		@employee_leave.user_id = User.current.id if @employee_leave.referral_id.blank?
    @employee_leave.referral_id = params[:systango_hrm_employee_leave][:referral_id] if params[:apply][:leave] == (SystangoHrm::Constants::REFER)
		@employee_leave.attributes = params[:systango_hrm_employee_leave]
  end

  def find_or_initialize_employee_leave
    @employee_leave = SystangoHrmEmployeeLeave.new if params[:action] == 'create'
    @employee_leave = SystangoHrmEmployeeLeave.find(params[:id]) if params[:action] == 'update'
  end
  
  def leave_application_details
    @request_recievers_for_leave = SystangoHrmRequestReceiver.by_application_id(params[:id])
    @request_reciever = SystangoHrmRequestReceiver.by_application_and_receiver_id(params[:id], User.current.id).first
  end

  def fetch_teamleads_subordinates
    @teamlead_users = SystangoHrmTeamleadsSubordinates.unlocked_teamleads_for(User.current.subordinates)
    @subordinate_users = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(User.current.teamleads)
  end
  
  def check_leave_account_is_created
		@leave_account = User.current.systango_hrm_leave_account
    if @leave_account.blank?
      flash.now[:error] = l(:leave_account_not_activated_error)
      render 'create_update_leaves'
    end
  end

  def leave_application_instance
    admins = User.admin_users
    active_and_admin_users = User.active_users - admins - [User.current]
    active_and_admin_users = active_and_admin_users - @teamlead_users if @teamlead_users
	  @teamlead_details = active_and_admin_users.sort_by{|e| e.firstname.titleize}
    @default_application_receivers = (admins + (@teamlead_users.blank? ? [] : @teamlead_users)).uniq
    @users_with_hr_permission = User.users_with_hr_permission.collect(&:id)
    @default_application_receivers = @default_application_receivers - [User.current] if (!@users_with_hr_permission.blank? and @users_with_hr_permission.include?(User.current.id))
		subordinates_with_leave_account = (User.current.teamleads.collect{|teamlead| teamlead if teamlead.subordinate_user.systango_hrm_leave_account}).compact
		@subordinates_with_leave_account = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(subordinates_with_leave_account)
		@subjects = SystangoHrmSubject.all_as_array
  end

  #[Palash]: Validation is put here because on model we are unable to decide type of leave.
	def validate_leave_type
		if (params[:systango_hrm_employee_leave] and params[:apply][:leave] == SystangoHrm::Constants::REFER and params[:systango_hrm_employee_leave][:referral_id].blank?)
			flash.now[:error] = l(:leave_referral_not_selected_error)
			render 'create_update_leaves'
		end
	end

  def authorize_to_view_application
    @leave_detail = SystangoHrmEmployeeLeave.find(params[:id]) rescue nil
    if @leave_detail.blank? or (SystangoHrmRequestReceiver.by_application_and_receiver_id(params[:id], User.current.id).blank? and !(User.current.id == (@leave_detail.applied_user.id)))
      flash[:error] = l(:application_view_authorisation_error)
      redirect_to home_path
    end
  end

	def date_and_subject_both_updated?(employee_leave,previous_leave_record)
		(previous_leave_record.subject_id == employee_leave.subject_id) and (previous_leave_record.leave_start_date.to_date == employee_leave.leave_start_date.to_date) and (previous_leave_record.leave_end_date.to_date == employee_leave.leave_end_date.to_date)
	end

	def request_receivers_entry_for_update(employee_leave,tl_admin_hr_ids)
		return SystangoHrmRequestReceiver.update_request_receivers(employee_leave,tl_admin_hr_ids) if !params[:receiver_id][:id].reject(&:empty?).blank?
		SystangoHrmRequestReceiver.change_status_to_pending_for_all_receivers(params[:id])
	end

end
