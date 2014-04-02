class SystangoHrmDesignationHistoriesController < SystangoHrmController
  unloadable

  before_filter :initialize_designation_history, :validate_field_without_promotion, only: :update

  def update
    begin
      if create_new_designation_history?
        @designation_history = SystangoHrmDesignationHistory.create(
                                   user_id: @designation_history.user_id,
                                   prev_designation_id: @designation_history.new_designation_id,
                                   new_designation_id:  params[:designation_id],
                                   applicable_from: params[:designation_history][:applicable_from],
                                   remarks: params[:designation_history][:remarks])
      else
        @designation_history.update_attributes(new_designation_id:  params[:designation_id],
                                   applicable_from: params[:designation_history][:applicable_from],
                                   remarks: params[:designation_history][:remarks])
      end
      render 'systango_hrm_employees/edit' and return unless @designation_history.errors.blank?
      flash[:notice] = l(:employee_leave_updated_notice)
      redirect_to edit_systango_hrm_employee_path(@designation_history.user_id)
    rescue
      flash.now[:error] = l(:proper_date_error_message)
      render 'systango_hrm_employees/edit'
    end  
  end
   
private

  def initialize_designation_history
    @designation_histories = User.find(params[:id]).systango_hrm_designation_histories.order_by_id_desc
    @designation_history = @designation_histories.first
    @leave_account = @designation_history.user.systango_hrm_leave_account
    @designations = SystangoHrmDesignation.all_as_array
  end

  # We put validation here becuase we not able to decide from where the desigantion is updated
  def validate_field_without_promotion
    return unless @designation_history.prev_designation_id.nil?
    begin
      if (@designation_history.new_designation_id != params[:designation_id].to_i) and (@designation_history.applicable_from == params[:designation_history][:applicable_from].to_date)
        flash.now[:error]= l(:designation_not_update_error)
      elsif (@designation_history.applicable_from != params[:designation_history][:applicable_from].to_date) and (@designation_history.new_designation_id == params[:designation_id].to_i)
        flash.now[:error] = l(:desgination_applicable_from_error)
      end
    rescue
      flash.now[:error] = l(:proper_date_error_message)
    end      
    render 'systango_hrm_employees/edit' unless flash.now[:error].blank?
  end

  def create_new_designation_history?
    (@designation_history.applicable_from.to_date != (params[:designation_history][:applicable_from]).to_date) and (@designation_history.new_designation_id != params[:designation_id].to_i)
  end

end
