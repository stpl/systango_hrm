require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmCompoffsTest < ActiveSupport::TestCase

  def test_validate_compoff
    compoff = SystangoHrmCompoff.new
    compoff.user_id = "1"
    compoff.comp_off_remarks = "Test remarks"

    [nil, 0.4, -1, 0].each do |value|
      compoff.comp_off_given = value
      assert_equal false, compoff.valid?
      assert_equal true, compoff.errors.has_key?(:comp_off_given)
    end

  end

  def test_leave_account_updated
    old_leaves_balance = SystangoHrmLeaveSummaryCurrentYear.where("user_id=?", 1).first.total_comp_off_provided
    SystangoHrmCompoff.create(:user_id => 1, :comp_off_given => 1, :comp_off_remarks => "Test remarsk3")
    new_leave_balance = SystangoHrmLeaveSummaryCurrentYear.where("user_id=?", 1).first.total_comp_off_provided
    assert_equal new_leave_balance, (old_leaves_balance + 1)
  end

end
