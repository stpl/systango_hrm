class SystangoHrmCompoff < SystangoHrmModel
  unloadable

  belongs_to :user

  
  validates :comp_off_remarks, :presence => {:message => l(:compoff_remarks_presence_true_error)}
  validates :user_id, :presence =>{:message => l(:leave_select_employee_name_error)}

  validate :validate_compoff_given

  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :order_by_created_desc, ->{order("created_at desc")} 
  
  def validate_compoff_given
    return errors.add(:comp_off_given, l(:compoff_blank_error)) if comp_off_given.blank?
    return errors.add(:comp_off_given, l(:compoff_zero_error_message)) if comp_off_given == 0
    return errors.add(:comp_off_given, l(:compoff_negative_error)) if comp_off_given <= 0
    return errors.add(:comp_off_given, l(:compoff_decimal_error_message)) unless comp_off_given % 0.5 == 0
  end

end
