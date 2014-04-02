module SystangoHrmEmployeeLeavesHelper

  include SystangoHrm::WelcomeHelperPatch

  def show_link_to_report?
	 (User.current.id == @leave_detail.referral_id) or ((User.current.id == @leave_detail.user_id) and @leave_detail.referral_id.blank?)
  end

  def show_details?
    ((!@request_reciever.blank? and !(User.current.id == (@leave_detail.applied_user.id) and User.current.allowed_to_globally?(:hr_permissions, {}))) or User.current.admin)
  end

  def current_user_is_applied_user?
    (User.current.id == (@leave_detail.applied_user.id))
  end

end
