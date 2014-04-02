require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmLeaveAccountTest < ActiveSupport::TestCase

ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_leave_accounts, :systango_hrm_designation_histories, :systango_hrm_designations, :users])

  def test_validate_current_designation
    leave_account = SystangoHrmLeaveAccount.new
    leave_account.user_id = "5"
    leave_account.date_of_joining = "2014-01-01"
    leave_account.is_eligible_for_maternity_leave = "1"
    assert_equal false, leave_account.save
    assert_equal true, leave_account.errors.has_key?(:current_designation)
  end

  def test_validate_maternity_leave
    leave_account = SystangoHrmLeaveAccount.find(1)
    leave_account.is_eligible_for_maternity_leave = "0"
    assert_equal false, leave_account.save
    assert_equal true, leave_account.errors.has_key?(:maternity_leave)
  end

  def test_leave_summary_and_designatoin_history_created
    leave_account = SystangoHrmLeaveAccount.create(:current_designation_id => 1, :user_id => User.last.id, :date_of_joining => "2014-01-01", :remarks => "Designation Added")
    assert_not_nil SystangoHrmDesignationHistory.by_user_id(User.last.id)
    assert_equal 16, leave_account.leave_summary_current_year.leaves_entitled
    assert_equal 1, leave_account.current_designation_id
  end

end
