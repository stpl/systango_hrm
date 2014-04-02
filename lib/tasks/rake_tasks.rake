namespace :systango_hrm do

  task :send_reminder_email_for_pending_leaves => :environment do
    SystangoHrmEmployeeLeave.leaves_in_next_5_and_1_days.each do |leave|
      recievers_ids = SystangoHrmRequestReceiver.by_application_id_and_status(leave.id, Constants::STATUS_PENDING).map(&:receiver_id)
      recievers_ids.each {|reciever_id| SystangoHrmMailer.delay.send_reminder_email(leave, (User.find(reciever_id).mail rescue ""))} 
    end
	end

	task :recalculate_leaves_on_holiday_calender_update => :environment do
		SystangoHrmLeaveAccount.with_active_user.map(&:user).compact.each do |user|
			total_leave = (user.self_employee_leaves + user.referred_employee_leaves).inject(0){|result, leave|
				result += (leave.approved? ? leave.leave_duration : 0)
			}
			(user.systango_hrm_leave_summary_current_year.update_attributes(leaves_taken: total_leave) rescue nil)
		end
	end

end