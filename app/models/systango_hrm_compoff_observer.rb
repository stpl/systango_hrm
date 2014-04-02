class SystangoHrmCompoffObserver < ActiveRecord::Observer
  def after_create(compoff)
  	leave_account = compoff.user.systango_hrm_leave_summary_current_year
    new_comp_offs = (leave_account.total_comp_off_provided  || 0) + (compoff.comp_off_given.to_f rescue 0)
    leave_account.update_attribute(:total_comp_off_provided, new_comp_offs)
    SystangoHrmMailer.delay.notify_compoff_added_to_employee(compoff, leave_account)
  end
end