class SystangoHrmCompoffsController < SystangoHrmController
  unloadable
  before_filter :compoff_instance
 
  def new
  end

	def create
  	@compoffs = User.find(params[:user_id]).systango_hrm_compoffs.order_by_created_desc rescue nil
		# check whether form is submitted by javascript or by submit button and to display the record of selected user.
		render 'new' and return if params[:commit].blank?
	  @compoff = SystangoHrmCompoff.new(params[:compoff].merge!(user_id: params[:user_id]))
	  if @compoff.save
      flash[:notice] = l(:leave_compoff_added_notice)
	    redirect_to new_systango_hrm_compoff_url
	  else
      render 'new'
	  end
	end

private

	def compoff_instance
    @users = SystangoHrmLeaveAccount.with_active_user.map(&:user).compact.sort_by(&:firstname) rescue nil
	end

end
