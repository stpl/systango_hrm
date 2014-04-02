class SystangoHrmRequestReceiver < SystangoHrmModel

  unloadable
  include SystangoHrm::SystangoHrmRequestReceiverStateMachine
  
  belongs_to :user, :class_name => "User", :foreign_key => 'receiver_id'
  belongs_to :systango_hrm_employee_leave, :foreign_key => 'application_id', :class_name => "SystangoHrmEmployeeLeave"
	scope :by_user_id, ->(user_id) { where(receiver_id: user_id) }
  scope :by_receiver_approval_status, ->(status) { where(receiver_approval_status: status) }
  scope :by_application_and_receiver_id, ->(application_id, receiver_id) { where(application_id: application_id, receiver_id: receiver_id) }
  scope :by_application_id, ->(application_id) { where(application_id: application_id) }
  scope :by_application_id_and_status, ->(application_id, status) {where(application_id:  application_id, receiver_approval_status: status)}
  scope :order_by_created_at_desc, ->{order("created_at desc")}

  
  validates :comment, :presence =>{:message => l(:leave_comment_not_added_error)}, on: :update

  def update_leave_status(unapproved = true, comment = "")
    (unapproved ? self.unapprove! : self.approve!) if self.update_attributes(comment: comment)
  end

  def receiver
    User.find(self.receiver_id) rescue nil
  end

  class << self
    #TODO :: Should be renamed to report_be_use_and_type
    def request_by_user_and_type(user = nil, type = nil)
		  recieved_requests = self
		  recieved_requests = recieved_requests.by_user_id(user.id) if user
	    recieved_requests = recieved_requests.by_receiver_approval_status(type) if type
	    User.remove_leaves_of_locked_users(recieved_requests.order_by_created_at_desc.map(&:systango_hrm_employee_leave))
	  end

	  def update_request_receivers(employee_leave, tl_admin_hr_ids)
      self.by_application_id(employee_leave.id).delete_all
		  tl_admin_hr_ids.each {|tl_admin_hr_id| self.create(application_id: employee_leave.id, receiver_id: tl_admin_hr_id) }
    end
    
    def change_status_to_pending_for_all_receivers(application_id)
      self.by_application_id(application_id).each do |request_receiver|
        request_receiver.update_attribute(:comment,  SystangoHrm::Constants::NONE)
        request_receiver.pending!
      end
    end
  end
    
end
