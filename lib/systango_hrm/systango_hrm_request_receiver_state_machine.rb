require 'state_machine'
require 'state_machine/core'

module SystangoHrm
  module SystangoHrmRequestReceiverStateMachine
  	def self.included(klass)
  	  klass.class_eval do 
        state_machine :receiver_approval_status, :initial => :pending do  
        
          event :approve do
            transition [:pending, :unapproved]  => :approved
          end

          event :unapprove do
            transition [:approved, :pending] => :unapproved
          end

          event :cancel  do
           transition [:pending, :approved, :unapproved]  => :cancel
          end

          event :pending do
            transition [:approved, :unapproved, :pending] => :pending
          end

          after_transition any => :approved, do: :after_approval
          after_transition any => :unapproved, do: :after_unapproval
        end
      end
  	end

    def after_approval
      self.systango_hrm_employee_leave.approve! if User.current.admin_user?
      after_approval_or_unapproval
    end

    def after_unapproval
      self.systango_hrm_employee_leave.unapprove! if User.current.admin_user?
      after_approval_or_unapproval
    end

    def after_approval_or_unapproval
      if User.current.admin_user?
        notify_all_after_final_update
      else
        notify_all_tls_of_update
      end
    end

    def notify_all_tls_of_update
      recievers = self.class.by_application_id(self.application_id).all.collect{|receiver| receiver.receiver.mail if receiver.receiver_id != User.current.id } 
      SystangoHrmMailer.delay.notify_tl_of_previous_leave(recievers, self.systango_hrm_employee_leave , self, User.current)
    end

    def notify_all_after_final_update
      employee_leave_obj = self.systango_hrm_employee_leave
      new_status = (User.current.admin_user? ? employee_leave_obj.status : self.receiver_approval_status)
      receivers = User.get_email_for_users(employee_leave_obj.systango_hrm_request_receivers.collect(&:receiver_id)) + [employee_leave_obj.applied_user.mail]
      SystangoHrmMailer.delay.notify_all_of_final_approval(employee_leave_obj, self, User.current, new_status, receivers)
    end
  end

end
