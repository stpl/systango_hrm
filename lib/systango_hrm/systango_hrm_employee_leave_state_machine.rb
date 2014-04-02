module SystangoHrm
	module SystangoHrmEmployeeLeaveStateMachine
    def self.included(klass) 
      klass.class_eval do 
        state_machine :status, :initial => :pending do  
          event :approve do
            transition [:pending, :unapproved, :approved] => :approved
          end

          event :unapprove do
            transition [:approved, :pending, :unapproved] => :unapproved
          end
          event :cancel do
            transition [:pending] => :cancel
          end

          after_transition :pending => :approved, do: :after_approval
          after_transition :unapproved => :approved, do: :after_approval
          after_transition :pending => :unapproved, do: :after_unapproval_from_pending
          after_transition :approved => :unapproved, do: :after_unapproval_from_approved
          after_transition any => :cancel, do: :after_cancel
        end
      end
    end
    
    def after_cancel
      request_receivers = SystangoHrmRequestReceiver.by_application_id(self.id)
      request_receivers.each do |request_reciever| 
        request_reciever.update_attribute(:comment,  SystangoHrm::Constants::NONE)
        request_reciever.cancel!
      end
      receivers = User.get_email_for_users(request_receivers.collect(&:receiver_id)) + [self.applied_user.mail]
      SystangoHrmMailer.delay.notify_all_of_leave_cancelled(self, User.current, receivers)
    end

    def after_approval
      applied_leave_duration = self.leave_duration
      user_leave_account = (self.applied_user).systango_hrm_leave_summary_current_year
      if self.is_maternity_leave
        user_leave_account.systango_hrm_leave_account.update_attribute(:is_eligible_for_maternity_leave, false)
      else
        leave_taken = ((user_leave_account.leaves_taken.to_f or 0.0) + applied_leave_duration)
        user_leave_account.update_attribute(:leaves_taken, leave_taken)
      end
    end

    def after_unapproval_from_approved
      after_unapproval_from_pending
      user_leave_account = (self.applied_user).systango_hrm_leave_summary_current_year
      leave_taken = ((user_leave_account.leaves_taken.to_f or 0.0) - leave_duration) unless self.is_maternity_leave
      user_leave_account.update_attribute(:leaves_taken, leave_taken)
    end

    def after_unapproval_from_pending
      user_leave_account = (self.applied_user).systango_hrm_leave_summary_current_year
      if self.is_maternity_leave
        user_leave_account.systango_hrm_leave_account.update_attribute(:is_eligible_for_maternity_leave, true)
      else
        user_leave_account.update_attribute(:leaves_taken, (user_leave_account.leaves_taken.to_f or 0.0))
      end
    end

	end
end
