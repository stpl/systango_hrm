class SystangoHrmLeaveReportsController < SystangoHrmController
  unloadable

  before_filter :leave_report_all_selected, :fetch_subordinates, :validate_teamlead_fields,
                :validate_date, only: :report
  before_filter :leave_account_not_exist, :fetch_data_to_show_report, :fetch_teamleads_subordinates, only: [:view_report_self, :show_user_report]

  def report
	  if @report_all
      @pending_leaves, @approved_leaves, @unapproved_leaves =  SystangoHrmEmployeeLeave.leave_report_all
	  else
      if !params[:leave].blank? and User.current.admin_user?
	      @report = SystangoHrmEmployeeLeave.leave_report_admin(params[:leave][:status], params[:leave][:leave_start_between],  params[:leave][:leave_end_between], params[:leave][:employee], params[:user_id], params[:designation_id])
        @leave_account = (User.find(params[:user_id]).systango_hrm_leave_account rescue nil) if (params[:leave][:employee] == SystangoHrm::Constants::NAME_WISE and !params[:user_id].blank?)
		  else
			  @report = SystangoHrmEmployeeLeave.by_user_id_or_referral_id(params[:user_id])
		  end
	    @report = User.remove_leaves_of_locked_users(@report).paginate(:page => params[:page], :per_page =>10) rescue nil if @report
	  end 
	end

  def show_user_report
  	render 'view_report_self'
  end
  
  ["pending", "approved", "unapproved"].each do |status|
    define_method status do
      @leave_status = status
      @all_leaves = SystangoHrmEmployeeLeave.by_status(@leave_status).paginate(:page => params[:page], :per_page => 10) rescue nil
      render 'view_more_leaves'
    end
  end

  def view_report_self
	end

private

  def fetch_subordinates    
    if User.current.admin_user?
      @subordinates = SystangoHrmLeaveAccount.with_active_user.map(&:user).compact.sort_by(&:firstname) rescue nil
	    @designations = SystangoHrmDesignation.all_as_array
	  else
      @subordinates = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(User.current.teamleads)
	  end
  end

  def validate_teamlead_fields
	  return if User.current.admin_user?
    if params[:user_id].blank? and !params[:commit].blank?
	    flash.now[:error] = l(:leave_select_employee_name_error)
	    render 'report'
    else
      @subordinates = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(User.current.teamleads)
    end
  end

  def validate_date
	  if valid_date_for_admin?
      flash.now[:error] = l(:leave_improper_dates_error)
      render 'report'      
    end
  end

  def valid_date_for_admin?
    (params[:leave] and ((!params[:leave][:leave_start_between].blank? and params[:leave][:leave_end_between].blank?) or (params[:leave][:leave_start_between].blank? and !params[:leave][:leave_end_between].blank?))) or
    (User.current.admin_user? and params[:leave] and (params[:leave][:leave_start_between] > params[:leave][:leave_end_between] rescue false))
  end

  def fetch_data_to_show_report
    #To view subordinates or self report
    unless params[:id].blank?
      leave = (SystangoHrmEmployeeLeave.find(params[:id]) rescue nil) if !params[:report]
      @user = (params[:report].blank? ? leave.applied_user : (User.find(params[:id]) rescue nil))
    else
      @user = User.current
    end
    @custom_value = CustomValue.value_employee_code(@user)
    @leave_account = @user.systango_hrm_leave_account rescue nil
		return unless @leave_account
    @self_records = (SystangoHrmEmployeeLeave.by_user_and_referral_id(@user.id, nil) + @user.referred_employee_leaves).sort_by(&:id).reverse.paginate(:page => params[:page], :per_page => 10) rescue nil
	  @compoffs = (SystangoHrmCompoff.by_user_id(@user.id)).order_by_created_desc
  end

  def fetch_teamleads_subordinates
    @subordinates = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(@user.teamleads)
    @teamleads = SystangoHrmTeamleadsSubordinates.unlocked_teamleads_for(@user.subordinates)
  end

  def leave_account_not_exist
    flash.now[:error] = l(:leave_report_no_record_exists_error) if (User.current.systango_hrm_leave_account.blank? and params[:action] == "view_report_self")
  end
      
  def leave_report_all_selected
    @options = [SystangoHrm::Constants::STATUS_ALL, SystangoHrm::Constants::APPROVED, SystangoHrm::Constants::UNAPPROVED, SystangoHrm::Constants::PENDING]
    return if params[:leave].blank?
    #used flag to recognize all reports request
    @report_all = (params[:leave][:leave_start_between].blank? and params[:leave][:leave_end_between].blank? and params[:user_id].blank? and params[:designation_id].blank? and params[:leave][:status] == SystangoHrm::Constants::STATUS_ALL) 
  end

end
