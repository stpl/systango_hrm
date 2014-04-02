class SystangoHrmLeaveAccountObserver < ActiveRecord::Observer

  def after_create(leave_account)
  	leave_summary_current_year = SystangoHrmLeaveSummaryCurrentYear.create(user_id: leave_account.user.id,  leaves_taken: 0, total_comp_off_provided: 0)
    designation_history = SystangoHrmDesignationHistory.create(user_id: leave_account.user.id, new_designation_id: leave_account.current_designation_id, applicable_from: leave_account.date_of_joining, remarks: leave_account.remarks)
  end
end
