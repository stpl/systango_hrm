class SystangoHrmDesignation < SystangoHrmModel
  unloadable
  
  include SystangoHrm::CachedModel
  

  has_many :previous_designations, :class_name => "SystangoHrmDesignationHistory", :foreign_key => "prev_designation_id", :primary_key => "id"
  has_many :new_designations, :class_name => "SystangoHrmDesignationHistory", :foreign_key => "new_designation_id", :primary_key => "id"
  has_many :leave_accounts, :class_name => "SystangoHrmLeaveAccount", :foreign_key => "current_designation_id", :primary_key => :id

  validates :designation,
  					:presence => {:message => l(:designation_blank_designation_field_error)}, 
					  :uniqueness => { :case_sensitive => false ,:message => l(:designation_duplicate_error)}
  validate :validate_leaves_entitled
  
  default_scope {order('designation asc')} 
 
  def designation=(designation)
    write_attribute(:designation, designation.strip)
  end

  def validate_leaves_entitled
    return errors.add(:leaves_entitled, l(:leaves_entitled_blank_error)) if leaves_entitled.blank?
    return errors.add(:leaves_entitled, l(:leaves_entitled_zero_error_message)) if leaves_entitled == 0
    return errors.add(:leaves_entitled, l(:leaves_entitled_negative_error)) if leaves_entitled <= 0
    return errors.add(:leaves_entitled, l(:leaves_entitled_decimal_error_message)) unless leaves_entitled % 0.5 == 0    
  end

end
