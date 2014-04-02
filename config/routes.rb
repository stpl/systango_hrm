resources :systango_hrm_employees, :only => [:edit,:update], path: 'employees'
get 'employees/new', :to => 'systango_hrm_employees#add_details'
post "employees/create_leave_account", :to => "systango_hrm_employees#create_leave_account"
get 'employees/context_menu', :to => "systango_hrm_employees#context_menu"

resources :systango_hrm_designation_histories, :only => [:edit,:update], path: 'designation_history'

resources :systango_hrm_designations, :except => [:show], path: 'designations'
get 'designations/context_menu', :to => "systango_hrm_designations#context_menu"

get 'teamleads/subordinates', :to => 'systango_hrm_teamleads#subordinates'
get 'teamleads/list', :to => 'systango_hrm_teamleads#teamleads_subordinates'
get 'teamleads/show', :to => 'systango_hrm_teamleads#show'
post 'teamleads/show', :to => 'systango_hrm_teamleads#show'
post 'teamleads/update', :to => 'systango_hrm_teamleads#add_or_remove_subordinates'
post 'teamleads/show_teamleads_subordinates', :to => 'systango_hrm_teamleads#show_teamleads_subordinates' 
get 'teamleads/show/autocomplete', :to => 'systango_hrm_teamleads#autocomplete_teamleads' 
get 'teamleads/show/autocomplete/subordinate', :to => 'systango_hrm_teamleads#autocomplete_subordinates' 

get 'report', :to => 'systango_hrm_leave_reports#report'
get 'leave/report/:id', :to => 'systango_hrm_leave_reports#show_user_report', :as => "leave/report"
get 'report/self', :to => 'systango_hrm_leave_reports#view_report_self'

resources :systango_hrm_compoffs , path: 'compoffs'

get 'leaves/manage', :to => 'systango_hrm_employee_leaves#manage_request'
post 'leaves/status', :to => 'systango_hrm_employee_leaves#update_leave_status'
get 'leaves/pending', :to=>'systango_hrm_employee_leaves#pending'
get 'leaves/approved', :to=>'systango_hrm_employee_leaves#approved'
get 'leaves/unapproved', :to=>'systango_hrm_employee_leaves#unapproved'

get 'leaves/report/pending', :to=>'systango_hrm_leave_reports#pending'
get 'leaves/report/approved', :to=>'systango_hrm_leave_reports#approved'
get 'leaves/report/unapproved', :to=>'systango_hrm_leave_reports#unapproved'

resources :systango_hrm_holidays , :except => [:show], path: 'holidays'
get 'holidays/calendar', :to => "systango_hrm_holidays#calendar"
get 'holidays/context_menu', :to => "systango_hrm_holidays#context_menu"

resources :systango_hrm_subjects, :except => [:show], path: 'subjects'
get 'subjects/context_menu', :to => "systango_hrm_subjects#context_menu"


resources :systango_hrm_employee_leaves , path: 'leaves'do
	get 'application', on: :member
end
