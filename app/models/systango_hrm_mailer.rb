class SystangoHrmMailer < Mailer

	def notify_compoff_added_to_employee(compoff, leave_account)
		@compoff, @leave_account = compoff.comp_off_given, leave_account
		mail(to: @leave_account.user.mail, subject: l(:mailer_subject_comp_off_added) )
	end

	def notify_employee_of_their_leave(leave,referred_by)
    @leave, @referred_by = leave, referred_by
	  subject = "#{@leave.systango_hrm_subject.subject} applied by #{@leave.applied_user.name.titleize rescue nil} from- #{@leave.leave_start_date.strftime("%b %d, %Y")} to- #{@leave.leave_end_date.strftime("%b %d, %Y")}"
	  mail(to: @leave.applied_user.mail, subject: subject)
  end
  
  def send_reminder_email(leave_details, receivers_emails)
		@leave = leave_details
		subject = "#{@leave.systango_hrm_subject.subject} applied by #{@leave.applied_user.name.titleize rescue nil} from- #{@leave.leave_start_date.strftime("%b %d, %Y")} to- #{@leave.leave_end_date.strftime("%b %d, %Y")}"
		mail(to: receivers_emails, subject: subject)
  end

  def notify_admin_tls_of_leave_request(receiver_ids, leave)
  	@leave = leave
		subject = "#{@leave.systango_hrm_subject.subject} applied by #{@leave.applied_user.name.titleize rescue nil} from- #{@leave.leave_start_date.strftime("%b %d, %Y")} to- #{@leave.leave_end_date.strftime("%b %d, %Y")}"
  	email_to = (User.get_email_for_users(receiver_ids)).join(',')
    mail(to: email_to, subject: subject)
  end

  def notify_all_of_leave_processing(receiver_ids, leave)
  	@leave = leave
  	subject = "#{@leave.systango_hrm_subject.subject} applied by #{@leave.applied_user.name.titleize rescue nil} from- #{@leave.leave_start_date.strftime("%b %d, %Y")} to- #{@leave.leave_end_date.strftime("%b %d, %Y")}"
  	email_to = (User.get_email_for_users(receiver_ids)).join(',')
    mail(to: email_to, subject: subject)
  end
  
  def notify_employee_of_leave_processing(leave, referred_by)
    @leave, @referred_by = leave, referred_by
	  subject = "#{@leave.systango_hrm_subject.subject} applied by #{@leave.applied_user.name.titleize rescue nil} from- #{@leave.leave_start_date.strftime("%b %d, %Y")} to- #{@leave.leave_end_date.strftime("%b %d, %Y")}"
	  mail(to: @leave.applied_user.mail, subject: subject)
  end

  def notify_subordinate_of_tl_updation(present_teamleads, teamlead_and_subordinate_id, is_added=false)
    @present_teamleads, @teamlead, @is_subordinate_added = present_teamleads, User.find(teamlead_and_subordinate_id[:teamlead_id]), is_added
		mail(to: User.find(teamlead_and_subordinate_id[:subordinate_id]).mail, subject: l(:mailer_subject_subordinate_update))
  end

	def notify_tl_of_subordinate_updation(teamlead_and_subordinate_id, for_admin=false, is_subordinate_added=false)
		@teamlead_user, @subordinate_user, @is_added =  User.find(teamlead_and_subordinate_id[:teamlead_id]), User.find(teamlead_and_subordinate_id[:subordinate_id]), is_subordinate_added
		mail_to = (for_admin ? User.admin_users.map(&:mail) : @teamlead_user.mail)
		mail_subject = (for_admin ? l(:mailer_subject_teamlead_subordinate_update) : l(:mailer_subject_teamlead_update))
		mail(to: mail_to, subject: mail_subject)
	end

	def notify_all_of_leave_updation(receivers_emails, leave_details, new_leave_details)
    @updated_leave = new_leave_details
    # we are not appliying association here because we are passing hash and that's why we put our business logic here
    @user = leave_details["referral_id"].blank? ? (User.find(leave_details["user_id"]) rescue nil) : (User.find(leave_details["referral_id"]) rescue nil)
    subject = "#{SystangoHrmSubject.find(leave_details["subject_id"]).subject} applied by #{@user.name.titleize} from- #{leave_details["leave_start_date"].strftime("%b %d, %Y")} to- #{leave_details["leave_end_date"].strftime("%b %d, %Y")}"
    email_to = (receivers_emails << @user.mail).join(',')
    mail(to: email_to, subject: subject)
	end
	
	def notify_tl_of_previous_leave(receivers_emails, leave, request_changed_by_user, current_user)
  	@leave_details, @changed_status, @user = leave, request_changed_by_user, current_user
		email_to = receivers_emails.join(',')
		subject = "#{@leave_details.systango_hrm_subject.subject} applied by #{@leave_details.applied_user.name.titleize rescue nil} from- #{@leave_details.leave_start_date.strftime("%b %d, %Y")} to- #{@leave_details.leave_end_date.strftime("%b %d, %Y")}"
		mail(to: email_to, subject: subject)
	end
	
  def notify_all_of_leave_cancelled(leave, current_user, receivers_emails)
		@leave_application, @current_user = leave, current_user
		email_to = receivers_emails.join(',')
		subject = "#{@leave_application.systango_hrm_subject.subject} applied by #{@leave_application.applied_user.name.titleize rescue nil} from- #{@leave_application.leave_start_date.strftime("%b %d, %Y")} to- #{@leave_application.leave_end_date.strftime("%b %d, %Y")}"
		mail(to: email_to, subject: subject)
	end

	def notify_all_of_final_approval(leave, request_changed_by_user, current_user, new_status, receivers_emails)
		@leave_application , @changed_status, @current_user, @new_status = leave, request_changed_by_user, current_user, new_status
		email_to = receivers_emails.join(',')
		subject = "#{@leave_application.systango_hrm_subject.subject} applied by #{@leave_application.applied_user.name.titleize rescue nil} from- #{@leave_application.leave_start_date.strftime("%b %d, %Y")} to- #{@leave_application.leave_end_date.strftime("%b %d, %Y")}"
		mail(to: email_to, subject: subject)
	end

end
