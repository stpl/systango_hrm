require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmRequestReceiversTest < ActiveSupport::TestCase

ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_employee_leaves, :systango_hrm_request_receivers, :systango_hrm_leave_summary_current_years, :systango_hrm_leave_accounts, :users])

  def test_update_leave_status
    reciever = SystangoHrmRequestReceiver.find(2)
    reciever.update_leave_status(true, comment = "sorry")
    assert_equal "unapproved", reciever.receiver_approval_status
    assert_equal "sorry", reciever.comment
  end

  def test_receiver
    assert_equal 2, SystangoHrmRequestReceiver.find(3).receiver.id
  end

  def test_request_by_user_and_type
    leaves = SystangoHrmRequestReceiver.request_by_user_and_type(User.find(1), SystangoHrm::Constants::STATUS_PENDING)
    assert_equal 1, leaves.count
    assert_equal 2, leaves.first.id
  end

  def test_update_request_receivers
    leave = SystangoHrmEmployeeLeave.first
    SystangoHrmRequestReceiver.update_request_receivers(leave, [2, 3])
    assert_equal 2, SystangoHrmRequestReceiver.by_application_id(leave.id).count
  end
end
