class SystangoHrmHolidaysController < SystangoHrmController
  unloadable

  helper :custom_fields
  helper :context_menus unless Redmine::VERSION.to_s < '1.4'
  include CustomFieldsHelper

  include SystangoHrm::ContextMenu
  generate_context_menu("holiday")

  before_filter :find_holidays, :only => [:index, :create, :calendar]
  before_filter :initialize_params, :only => [:index, :create]
  
  def calendar
  end

  def index
  end

	def create
		if @holiday.save
			flash[:notice] = l(:holiday_created_notice)
			redirect_to systango_hrm_holidays_path
		else
			render 'index'
		end
	end

	def edit
		@holiday = SystangoHrmHoliday.find(params[:id])
	end

	def update
		@holiday = SystangoHrmHoliday.find(params[:holiday][:id])
		@holiday.attributes = params[:holiday]
		if @holiday.save
			flash[:notice] = l(:holiday_update_notice)
			redirect_to systango_hrm_holidays_path
		else
			render 'edit'
		end
	end

private

  def find_holidays
	 	@holidays = SystangoHrmHoliday.order_by_holiday_desc
  end
  
  def initialize_params
    @holiday = SystangoHrmHoliday.new(params[:holiday])
  end

end
