class SystangoHrmHookListener < Redmine::Hook::ViewListener
	render_on :view_welcome_index_right, :partial => "systango_hrm_employee_leaves/my_page"
  render_on :view_welcome_index_left, :partial => "systango_hrm_employee_leaves/hr_hook"
end
