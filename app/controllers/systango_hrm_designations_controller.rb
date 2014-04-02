class SystangoHrmDesignationsController < SystangoHrmController
  unloadable
  include CustomFieldsHelper

  helper :context_menus unless Redmine::VERSION.to_s < '1.4'
  include SystangoHrm::ContextMenu
  generate_context_menu("designation")
  
  before_filter :intialize_and_fetch_designations, only:[:index, :create]

  helper :custom_fields
  
  def index
  end
	
	def create
		if @designation.save
			flash[:notice] = l(:designation_created_notice)
			redirect_to systango_hrm_designations_path
		else
			render 'index'
		end
	end

	def edit
		@designation = SystangoHrmDesignation.find(params[:id])
	end

	def update
		@designation = SystangoHrmDesignation.find(params[:designation][:id])
		@designation.attributes = params[:designation]
		if @designation.save
			flash[:notice] = l(:designation_update_notice)
			redirect_to systango_hrm_designations_path
		else
			render 'edit'
		end
	end

private

  def intialize_and_fetch_designations
		@designation = SystangoHrmDesignation.new(params[:designation])
	  @existing_designations = SystangoHrmDesignation.all_as_array
  end

end
