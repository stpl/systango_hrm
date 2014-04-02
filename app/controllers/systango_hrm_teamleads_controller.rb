class SystangoHrmTeamleadsController < SystangoHrmController
  unloadable
  
	before_filter :validate_subordinates, only: :add_or_remove_subordinates
	before_filter :employee_instance , only: [:subordinates, :teamleads_subordinates, :show, :show_teamleads_subordinates]

	def show
		begin
		  @teamlead = User.find(params[:teamlead_user_id]) 
	    if (@teamlead.allowed_to_globally?(:manage_leave_request, {}) or @teamlead.allowed_to_globally?(:hr_permissions, {}))
	      @subordinates = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(@teamlead.teamleads)
			  @non_subordinates = User.active_users_to_add(@subordinates.map(&:id) << params[:teamlead_user_id].to_i)
			  @non_subordinates = (@non_subordinates.collect{|non_subordinate| non_subordinate unless non_subordinate.systango_hrm_leave_account.blank?}).compact
		  else
		    @user_not_have_manage_leaves_permission = true
	    end
	    render "subordinates"
    rescue
    	flash.now[:error]= l(:mandatory_fields_not_selected_error)
    	render "subordinates"
  	end
	end

	def add_or_remove_subordinates
		teamlead_id = params[:teamlead_subordinate][:teamlead_id]
		if params[:remove]
			params[:subordinate][:user_ids].each do |subordinate_id|
			  SystangoHrmTeamleadsSubordinates.by_teamlead_and_subordinate_user_id(teamlead_id, subordinate_id).first.destroy rescue nil
		  end
			flash[:notice] = l(:teamlead_subordinates_removed_notice)
			redirect_to teamleads_show_path(:teamlead_user_id => teamlead_id)
		else
    	params[:non_subordinate][:user_ids].each do |subordinate_id|
      	SystangoHrmTeamleadsSubordinates.create(teamlead_user_id: teamlead_id, subordinate_user_id: subordinate_id)
	    end
		  flash[:notice] = l(:teamlead_subordinate_added_notice)
  	  redirect_to teamleads_show_path(:teamlead_user_id => params[:teamlead_subordinate][:teamlead_id])
		end
	end

	def autocomplete_subordinates
 		user = User.find(params[:format]) 
 		#params[:q] is not replace with params[:username] here beacuse we are using redmine core functionality.
 		subordinates = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(user.teamleads)
    @subordinates = User.subordinates_to_add_or_remove(subordinates.map(&:id) << params[:format].to_i, params[:q]).active_users.order_by_firstname_asc - [user]
		render :template => "systango_hrm_teamleads/autocomplete", :locals => {:autocomplete_user => 'subordinate', :users => @subordinates} ,:layout => false
	end

	def autocomplete_teamleads
	  user = User.find(params[:format]) 
		subordinates = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(user.teamleads)
		non_subordinates = SystangoHrmLeaveAccount.all.map(&:user) - subordinates
		@non_subordinates = User.subordinates_to_add_or_remove(non_subordinates.map(&:id) << params[:format].to_i, params[:q]).active_users.order_by_firstname_asc - [user]
  	render :template => "systango_hrm_teamleads/autocomplete", :locals => {:autocomplete_user => 'non_subordinate', :users => @non_subordinates}, :layout => false
	end

	def show_teamleads_subordinates
		begin
	  	@user = User.find(params[:user_id])
			@teamleads = SystangoHrmTeamleadsSubordinates.unlocked_teamleads_for(@user.subordinates)
			@subordinates = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(@user.teamleads)
			render 'teamleads_subordinates'
		rescue
			flash.now[:error]= l(:mandatory_fields_not_selected_error)
			render 'teamleads_subordinates'
		end
	end

  def subordinates
  end

  def teamleads_subordinates
  end

private

	def validate_subordinates
 		if params[:remove] and params[:subordinate].nil?
      flash[:error] = l(:subordinate_not_selected_to_remove_error)
 			redirect_to teamleads_show_path(:teamlead_user_id => params[:teamlead_subordinate][:teamlead_id])
 		elsif params[:add] and params[:non_subordinate].nil?
		  flash[:error] = l(:subordinate_not_selected_error)
 			redirect_to teamleads_show_path(:teamlead_user_id => params[:teamlead_subordinate][:teamlead_id])
 		end
	end

	def employee_instance
    @employees = SystangoHrmLeaveAccount.with_active_user.map(&:user).compact.sort_by(&:firstname) rescue nil
	end

end
