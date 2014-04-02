class SystangoHrmSubjectsController < SystangoHrmController
  unloadable

  helper :custom_fields
  helper :context_menus unless Redmine::VERSION.to_s < '1.4'
  include CustomFieldsHelper
  include SystangoHrm::ContextMenu
  generate_context_menu("subject")
  
  def new
    @subjects = SystangoHrmSubject.all_as_array
  end

  def create
  	@subject = SystangoHrmSubject.new(params[:subject])
  	if @subject.save
  		flash[:notice] = l(:leave_category_added_notice)
  		redirect_to new_systango_hrm_subject_path
  	else
  	  @subjects = SystangoHrmSubject.all_as_array
  		render 'new'
  	end
  end

  def edit
		@subject = SystangoHrmSubject.find(params[:id])
	end

	def update
		@subject = SystangoHrmSubject.find(params[:id])
		@subject.attributes = params[:subject]
		if @subject.save
			flash[:notice] = l(:category_update_notice)
			redirect_to new_systango_hrm_subject_path
		else
			render 'edit'
		end
	end
	
end
