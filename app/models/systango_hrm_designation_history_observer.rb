class SystangoHrmDesignationHistoryObserver < ActiveRecord::Observer
  def after_save(dh)
    update_leave_account_and_summary_current_year(dh)
  end

  def after_create(dh)
    update_leave_account_and_summary_current_year(dh)
  end

  def update_leave_account_and_summary_current_year(dh)
    dh.user.systango_hrm_leave_summary_current_year.update_attribute(:leaves_entitled, get_leaves_entitled_for_user(dh)) rescue nil
    dh.user.systango_hrm_leave_account.update_attribute("current_designation_id",dh.new_designation_id)
  end

  def get_leaves_entitled_for_user(dh)
    leaves_entitled = dh.class.applicable_histories_for_current_year(dh.user.id).inject(0) do |result, relevant_history|
      result += relevant_history.leaves_entitled_during_new_designation_for_current_year rescue 0
      result
    end
    round_off_leaves(leaves_entitled)
  end

  def round_off_leaves(leave_count)
    ((leave_count.to_f - leave_count.to_i >= 0.5) ? (leave_count.to_i + 0.5) : leave_count.to_i).to_f rescue nil
  end
  
end
