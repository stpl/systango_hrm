class SystangoHrmSubject < SystangoHrmModel

  unloadable
  include SystangoHrm::CachedModel
  validates :subject,
          	:presence => {:message => l(:subject_presence_true_error)}
	
  belongs_to :systango_hrm_employee_leave, :foreign_key => "id"
  
  default_scope  {order('subject asc')} 

end
