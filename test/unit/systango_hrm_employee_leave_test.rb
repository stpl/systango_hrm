require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmEmployeeLeaveTest < ActiveSupport::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_employee_leaves, :systango_hrm_holidays, :systango_hrm_request_receivers, :systango_hrm_subjects, :systango_hrm_designations, :users, :systango_hrm_leave_accounts])

  def test_validations(leave_attribute, sec)
    employee_leave = SystangoHrmEmployeeLeave.new(leave_attribute)
    assert_equal false, employee_leave.valid?
    assert_equal true, employee_leave.errors.has_key?(sec.to_sym)
  end

  def create_leave_attributes(user_id, half_day, maternity_leave, start_date, end_date, subject, remark, referral_id)
    {:user_id => user_id, :is_half_day => half_day, :is_maternity_leave => maternity_leave, :leave_start_date => start_date, :leave_end_date => end_date, :subject_id => subject, :remark => remark, :referral_id => referral_id}
  end

  def test_validate_date_and_time
    test_validations(create_leave_attributes(1, 1, 0, "", "", 1, "Test Remarks", nil), "date")
    test_validations(create_leave_attributes(1, 1, 0, "2014-01-03", "2014-01-02", 1, "Test Remarks", nil), "date")
    test_validations(create_leave_attributes(1, 1, 0, "2014-01-01", "2014-01-02", 1, "Test Remarks", nil), "half_day_date")
    test_validations(create_leave_attributes(1, 1, 0, "2014-03-11 08:00 pm", "2014-03-11 02:00 pm", 1, "Test Remarks", nil), "half_day_time")
    test_validations(create_leave_attributes(1, 1, 1, "2014-01-01", "2014-01-01", 1, "Test Remarks", nil), "half_day_and_maternity_leave")
  end

  def test_validate_ml_leave
    test_validations(create_leave_attributes(1, 0, 1, "2014-01-01", "2014-04-30", 1, "Test Remarks", nil), "maternity_leave_days")
    test_validations(create_leave_attributes(1, 0, 1, "2014-01-01", "2014-04-30", 1, "Test Remarks", 1), "maternity_leave_referred")
  end

  def test_leave_duration
    assert_equal 0, SystangoHrmEmployeeLeave.find(1).leave_duration
  end

  def test_leave_type
    assert_equal "Full Day", SystangoHrmEmployeeLeave.find(1).leave_type
    assert_equal "Half Day", SystangoHrmEmployeeLeave.find(2).leave_type
  end

  def test_applied_user
    assert_equal (User.find(1)), SystangoHrmEmployeeLeave.find(1).applied_user
    assert_equal (User.find(2)), SystangoHrmEmployeeLeave.find(6).applied_user
  end

  def test_date_falls_on_weekend_or_holiday
    assert_equal false, SystangoHrmEmployeeLeave.date_falls_on_weekend_or_holiday?(Date.today)
    assert_equal true, SystangoHrmEmployeeLeave.date_falls_on_weekend_or_holiday?("2014-12-31".to_date)
  end

  def test_date_falls_on_weekend
    assert_equal true, SystangoHrmEmployeeLeave.date_falls_on_weekend?("2014-03-29".to_date)
    assert_equal false, SystangoHrmEmployeeLeave.date_falls_on_weekend?("2014-12-31".to_date)
  end

  def test_date_falls_on_holiday
    assert_equal true, SystangoHrmEmployeeLeave.date_falls_on_holiday?("2014-12-31".to_date)
    assert_equal false, SystangoHrmEmployeeLeave.date_falls_on_holiday?("2014-03-03".to_date)
  end

  def test_leave_report_admin
    [{status: SystangoHrm::Constants::PENDING, result: [2, 3]}, {status: SystangoHrm::Constants::APPROVED, result: [1,4]}, {status: SystangoHrm::Constants::UNAPPROVED, result: [5, 6]}].each do |value|
      report = SystangoHrmEmployeeLeave.leave_report_admin(value[:status], nil, nil, nil, nil, nil)
      assert_equal (value[:result]), report.collect(&:id)
    end

    report = SystangoHrmEmployeeLeave.leave_report_admin(SystangoHrm::Constants::STATUS_ALL, nil, nil, SystangoHrm::Constants::NAME_WISE, 1, nil)
    assert_equal ([1, 2, 3]), report.collect(&:id)

    report = SystangoHrmEmployeeLeave.leave_report_admin(SystangoHrm::Constants::STATUS_ALL, nil, nil, SystangoHrm::Constants::DESIGNATION_WISE, nil, 1)
    assert_equal ([1, 2, 3]), report.collect(&:id)

    report = SystangoHrmEmployeeLeave.leave_report_admin(SystangoHrm::Constants::STATUS_ALL, "2014-03-12", "2014-03-12", nil, nil, nil)
    assert_equal ([1, 4, 5, 6]), report.collect(&:id)

    [{status: SystangoHrm::Constants::PENDING, user_id: 1, result: [2, 3]}, {status: SystangoHrm::Constants::APPROVED, user_id: 1, result: [1]}, {status: SystangoHrm::Constants::UNAPPROVED, user_id: 2, result: [6]}].each do |value|
      report = SystangoHrmEmployeeLeave.leave_report_admin(value[:status], nil, nil, SystangoHrm::Constants::NAME_WISE, value[:user_id], nil)
      assert_equal (value[:result]), report.collect(&:id)
    end

    common_hash_with_status_all = {status: SystangoHrm::Constants::STATUS_ALL, start_date: "2014-03-11", end_date: "2014-03-11"}
    common_hash_with_status_pending = {status: SystangoHrm::Constants::PENDING, start_date: "2014-03-11", end_date: "2014-03-11"}
    common_hash_with_status_approved = {status: SystangoHrm::Constants::APPROVED, start_date: "2014-03-12", end_date: "2014-03-12"}
    common_hash_with_status_unaapproved = {status: SystangoHrm::Constants::UNAPPROVED, start_date: "2014-03-12", end_date: "2014-03-12"}

    [{user_id: 1, result: [2]}.merge(common_hash_with_status_all),
      { user_id: 1, result: [2]}.merge(common_hash_with_status_pending),
      {user_id: 1, result: [1]}.merge(common_hash_with_status_approved),
      {user_id: 2, result: [6]}.merge(common_hash_with_status_unaapproved)
    ].each do |value|
      report = report = SystangoHrmEmployeeLeave.leave_report_admin(value[:status], value[:start_date], value[:end_date], SystangoHrm::Constants::NAME_WISE, value[:user_id], nil)
      assert_equal (value[:result]), report.collect(&:id)
    end

    [{desgnation_id: 1, result: [2]}.merge(common_hash_with_status_all), 
      {desgnation_id: 1, result: [2]}.merge(common_hash_with_status_pending),
      {desgnation_id: 1, result: [1]}.merge(common_hash_with_status_approved),
      {desgnation_id: 2, result: [5, 6]}.merge(common_hash_with_status_unaapproved)
    ].each do |value|
      report = SystangoHrmEmployeeLeave.leave_report_admin(value[:status], value[:start_date], value[:end_date], SystangoHrm::Constants::DESIGNATION_WISE, nil, value[:desgnation_id])
      assert_equal (value[:result]), report.collect(&:id)
    end

    [{status: SystangoHrm::Constants::PENDING, desgnation_id: 1, result: [2, 3]}, 
      {status: SystangoHrm::Constants::APPROVED, desgnation_id: 1, result: [1]}, 
      {status: SystangoHrm::Constants::UNAPPROVED, desgnation_id: 2, result: [5, 6]}
    ].each do |value|
      report = SystangoHrmEmployeeLeave.leave_report_admin(value[:status], nil, nil, SystangoHrm::Constants::DESIGNATION_WISE, nil, value[:desgnation_id])
      assert_equal (value[:result]), report.collect(&:id)
    end

    [{result: [2]}.merge(common_hash_with_status_pending),
      {result: [1, 4]}.merge(common_hash_with_status_approved),
      {result: [5, 6]}.merge(common_hash_with_status_unaapproved)
    ].each do |value|
      report = SystangoHrmEmployeeLeave.leave_report_admin(value[:status], value[:start_date], value[:end_date], SystangoHrm::Constants::NAME_WISE, nil, nil)
      assert_equal (value[:result]), report.collect(&:id)
    end
  end

  def test_leave_report_all
    assert_equal (SystangoHrmEmployeeLeave.count), SystangoHrmEmployeeLeave.leave_report_all.flatten.count
  end

  def test_pending_leaves
    assert_equal 2, SystangoHrmEmployeeLeave.pending_leaves.flatten.count
  end

  def test_approved_leaves
    assert_equal 2, SystangoHrmEmployeeLeave.approved_leaves.flatten.count
  end

  def test_unapproved_leaves
    assert_equal 2, SystangoHrmEmployeeLeave.unapproved_leaves.flatten.count
  end

  def test_emails_delivered_after_leave_created
    employee_leave = SystangoHrmEmployeeLeave.create(:user_id => 1, :is_half_day => 1, :leave_start_date => DateTime.now, :leave_end_date => DateTime.now, :subject_id => 1, :remark => "Test Case remarks")
    assert_equal true, employee_leave.is_a?(SystangoHrmEmployeeLeave)
    assert_equal 2, Delayed::Job.count  
  end

  def test_emails_delivered_after_leave_updated
    employee_leave = SystangoHrmEmployeeLeave.find(2)
    employee_leave.leave_start_date = DateTime.now
    employee_leave.leave_end_date = DateTime.now
    assert_equal true, employee_leave.save!
    assert_equal 2, Delayed::Job.count
  end

end
