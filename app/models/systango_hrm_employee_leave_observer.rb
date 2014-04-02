class SystangoHrmEmployeeLeaveObserver < ActiveRecord::Observer

  def after_create(leave)
    referred_by = (leave.referral_id.blank? ? SystangoHrm::Constants::SELF : leave.user.name.titleize) 
    SystangoHrmMailer.delay.notify_employee_of_their_leave(leave, referred_by)
    SystangoHrmMailer.delay.notify_admin_tls_of_leave_request(leave.systango_hrm_request_receivers.collect(&:receiver_id), leave)
  end

  def after_update(leave)
    notify_for_pending_leave(leave) if leave.pending?
  end

  def notify_for_pending_leave(leave)
    referred_by = (leave.referral_id.blank? ? SystangoHrm::Constants::SELF : leave.user.name.titleize)
    if (leave.leave_start_date_change.uniq.count == 1) and (leave.leave_end_date_change.uniq.count == 1) and (!leave.subject_id_changed?)
      SystangoHrmMailer.delay.notify_all_of_leave_processing(leave.systango_hrm_request_receivers.collect(&:receiver_id), leave)
      SystangoHrmMailer.delay.notify_employee_of_leave_processing(leave, referred_by)
    else
      SystangoHrmMailer.delay.notify_employee_of_their_leave(leave, referred_by)
      SystangoHrmMailer.delay.notify_admin_tls_of_leave_request(leave.systango_hrm_request_receivers.collect(&:receiver_id), leave)
    end
  end
  
end