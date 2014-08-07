require 'project'
Rails.application.config.to_prepare do
  SystangoHrm.apply_patch
end

Redmine::Plugin.register :systango_hrm do
  name 'systango_hrm'
  author 'Systango'
  description 'This is a plugin for leave management for Redmine'
  version '1.0.1'
#  url 'http:www.systango.com'
#  author_url 'http:www.systango.com'
  ActiveRecord::Base.observers += [:systango_hrm_compoff_observer, :systango_hrm_designation_history_observer, :systango_hrm_leave_account_observer, :systango_hrm_teamleads_subordinates_observer, :systango_hrm_employee_leave_observer]

	project_module :systango_hrm do

		permission :apply_leave, :systango_hrm_employee_leaves => [:new, :create, :application, :edit, :update, :update_leave_status, :index]
		permission :view_leave_report_self, :systango_hrm_leave_reports => :view_report_self, :systango_hrm_employee_leaves => :index
		permission :manage_leave_request, :systango_hrm_employee_leaves => [:application, :update_leave_status, :manage_request, :more_leaves, :approved, :unapproved, :pending, :edit, :update, :index]
		permission :view_leave_report_hr_or_tl,	:systango_hrm_leave_reports => [:report, :show_user_report, :pending, :approved, :unapproved], :systango_hrm_employee_leaves => :index
		permission :add_compoff_details, :systango_hrm_compoffs => [:new, :create], :systango_hrm_employee_leaves => :index
		permission :add_teamlead_subordinates_details, :systango_hrm_teamleads => [:add_or_remove_subordinates, :show, :subordinates, :autocomplete_subordinates, :autocomplete], :systango_hrm_employee_leaves => :index
		permission :show_subordinate_and_its_teamlead, :systango_hrm_teamleads => [:show_teamleads_subordinates, :teamleads_subordinates], :systango_hrm_employee_leaves => :index
  	permission :add_designation_wise_entitled_leaves, :systango_hrm_designations => [:index, :create, :edit, :update, :context_menu], :systango_hrm_employee_leaves => :index
		permission :add_employee_leave_details,	
		  :systango_hrm_employees => [:context_menu, :add_details, :create_leave_account, :update, :edit],
		  :systango_hrm_designation_histories => [:update], :systango_hrm_employee_leaves => :index
 		permission :add_subject_for_leave, :systango_hrm_subjects => [:new, :create, :context_menu, :edit, :update], :systango_hrm_employee_leaves => :index
    permission :add_holiday_calendar, :systango_hrm_holidays => [:index, :create, :edit, :update,:context_menu, :recalculate], :systango_hrm_employee_leaves => :index
		permission :hr_permissions, {
      :systango_hrm_employee_leaves => [:new, :create, :application, :edit, :update, :update_leave_status, :index,:application, :manage_request, :more_leaves, :approved, :unapproved, :pending, :edit, :update],
      :systango_hrm_leave_reports => [:report, :show_user_report, :view_report_self, :pending, :approved, :unapproved],
      :systango_hrm_compoffs => [:new, :create],
      :systango_hrm_teamleads => [:add_or_remove_subordinates, :show, :subordinates, :autocomplete_subordinates, :autocomplete,
                                  :show_teamleads_subordinates, :teamleads_subordinates],
      :systango_hrm_designations => [:index, :create, :edit, :update, :context_menu],
      :systango_hrm_employees => [:context_menu, :add_details, :create_leave_account, :update, :edit],
		  :systango_hrm_designation_histories => [:update],
		  :systango_hrm_subjects => [:new, :create, :context_menu, :edit, :update],
      :systango_hrm_holidays => [:index, :create, :edit, :update, :context_menu, :recalculate]
		}

	end
	menu :top_menu, :systango_hrm, {:controller => 'systango_hrm_employee_leaves', :action => 'index'}, :caption => "Leaves", :if => Proc.new {
    User.current.allowed_to?({:controller => 'systango_hrm_employee_leaves', :action => 'index'}, nil, {:global => true})
  }

  require 'systango_hrm_hook_listener.rb'
  require 'will_paginate/array'
end
