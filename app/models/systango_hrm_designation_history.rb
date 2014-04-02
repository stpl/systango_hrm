class SystangoHrmDesignationHistory < SystangoHrmModel

  unloadable
  belongs_to :user
  
  belongs_to :prev_designation, :class_name => "SystangoHrmDesignation", :foreign_key => "prev_designation_id", :primary_key => :id
  belongs_to :new_designation, :class_name => "SystangoHrmDesignation", :foreign_key => "new_designation_id", :primary_key => :id
  validates :applicable_from, :presence => {:message => l(:applicable_from_blank_error)}, :format => { :with => SystangoHrm::Constants::DATE_FORMAT_REGEX, :message=> l(:proper_date_error_message)}

  
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }
  scope :order_by_id_desc, ->{order("id DESC")}
  validate :validate_applicable_from

  def validate_applicable_from
    #self.user.systango_hrm_designation_histories we also do this what we will do please let us know
    desigantion_histroy_previous = self.class.by_user_id(user_id).order_by_id_desc
    return if desigantion_histroy_previous.blank? or prev_designation_id.nil?
    errors.add(:applicable_from, l(:applicable_from_and_date_of_joining_error)) if (self.user.systango_hrm_leave_account.date_of_joining >= applicable_from)
    if desigantion_histroy_previous.first.new_designation_id == new_designation_id and desigantion_histroy_previous.first.applicable_from != applicable_from
      errors.add(:applicable_from, l(:desgination_date_smaller_than_previoius_error)) if desigantion_histroy_previous.count > 1  and desigantion_histroy_previous.second.applicable_from > applicable_from
    end
  end


  def leaves_entitled_during_new_designation_for_current_year
    if self.next.nil? || self.next.applicable_from.year != Date.today.year
      num_months = (12 - applicable_from_month) + 1
    else
      num_months = self.next.applicable_from_month - self.applicable_from_month
    end
    leaves_entitled_for_designation_in_num_months(new_designation_id, num_months)     
  end

  def previous
    (self.class.where("user_id = ? and new_designation_id = ?",self.user_id, self.prev_designation_id).first) rescue nil
  end

  def next
    (self.class.where("user_id = ? and prev_designation_id = ?",self.user_id, self.new_designation_id).first) rescue nil
  end

  def applicable_from_month
     return 1 if self.applicable_from.year < Date.today.year # The history record is of previous year 
    get_months_applicable_based_on_date(self.applicable_from)
  end

  def self.applicable_histories_for_current_year(user_id)
    all_histories_for_user = by_user_id(user_id).order_by_id_desc rescue nil
    return nil if all_histories_for_user.nil?
    relevant_histories = all_histories_for_user.select{|history| history.applicable_from.year == Date.today.year }
    if relevant_histories.blank?
      [all_histories_for_user.first]
    else
      (relevant_histories.last.applicable_from_month == 1) ? relevant_histories  : (relevant_histories + [relevant_histories.last.previous])
    end
  end

private

  def get_months_applicable_based_on_date(date)
    (date.day > 15 ? date.month+1 : date.month)
  end

  def leaves_entitled_for_designation_in_num_months(designation_id, num_months)
    (((num_months/12.0).to_f) *  (SystangoHrmDesignation.find(designation_id).leaves_entitled))  rescue nil
  end

end
