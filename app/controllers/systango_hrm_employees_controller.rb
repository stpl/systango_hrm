class SystangoHrmEmployeesController < SystangoHrmController
  unloadable

  helper :context_menus unless Redmine::VERSION.to_s < '1.4'
  helper :custom_fields
  include CustomFieldsHelper

  before_filter :initialize_designation_history_and_leave_account, only: [:edit, :update]
  before_filter :fetch_user_accounts, only: [:add_details, :create_leave_account, :edit, :update]
  before_filter :initialize_leave_account, only: :update

	def add_details
	end

  def create_leave_account
    employee_ids = (params[:record][:user_id]).reject(&:empty?)
    leave_account_error = false
    unless employee_ids.blank?
      employee_ids.each do |employee_id|
        @leave_account = SystangoHrmLeaveAccount.create(:date_of_joining =>params[:record][:date_of_joining], :current_designation_id => params[:designation_id], :user_id => employee_id, :is_eligible_for_maternity_leave => (params[:record][:maternity_leave] == "1"), :remarks => params[:record][:remarks])
        if @leave_account.errors.any?
          leave_account_error = true
      	 	break
        end
      end
    else
      leave_account_error = true
      flash.now[:error] = l(:mandatory_fields_not_selected_error)
    end
    render 'add_details' and return if leave_account_error
    flash[:notice] = l(:employee_leave_added_notice)  
    redirect_to employees_new_path
 	end

 	def edit
 	end
 	
 	def update
   	@leave_account.is_eligible_for_maternity_leave = (params[:employee_leave_account][:maternity_leave] == "1")
    if @leave_account.save
      @leave_account.systango_hrm_designation_histories.last.update_attributes(:new_designation_id => params[:designation_id], :applicable_from => params[:employee_leave_account][:date_of_joining]) if @designation_histories.last.prev_designation_id.nil?
      flash[:notice] = l(:employee_leave_updated_notice)
      redirect_to employees_new_path
    else 
      render 'edit'
    end  
 	end

  #kept this method here because we are finding leave_account of user by user_id field.
  def context_menu
    @leave_accounts = SystangoHrmLeaveAccount.by_user_id(params[:selected_leave_accounts])
    @leave_account = @leave_accounts.first if (@leave_accounts.size == 1)
    @can = {:edit => true}
    render :layout => false
  end

private

  def initialize_leave_account
    return unless @designation_histories.last.prev_designation_id.nil?
    @leave_account = User.find(params[:id]).systango_hrm_leave_account
    @leave_account.date_of_joining = params[:employee_leave_account][:date_of_joining]
    @leave_account.current_designation_id = params[:designation_id]
  end

  def fetch_user_accounts
    @users_not_having_leave_account = User.active_users_without_leave_account
    @users_having_leave_account = SystangoHrmLeaveAccount.paginate(:page => params[:page], :per_page => 10,:joins=> :user,:order=> 'firstname asc')
    @designations = SystangoHrmDesignation.all_as_array
  end


  def initialize_designation_history_and_leave_account
    @designation_histories = User.find(params[:id]).systango_hrm_designation_histories
    @designation_history = @designation_histories.last
    @leave_account = @designation_history.user.systango_hrm_leave_account
  end

end
