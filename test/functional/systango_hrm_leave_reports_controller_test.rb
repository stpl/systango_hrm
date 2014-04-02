require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmLeaveReportsControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_leave_accounts, :systango_hrm_employee_leaves, :systango_hrm_designations, :systango_hrm_teamleads_subordinates, :users])

  def test_require_login_filter
    @request.session[:user_id] = nil
    ['report', 'view_report_self'].each do |action |
      get action.to_sym
      assert_response 302
    end
  end

  def test_validate_teamlead_fields
    @request.session[:user_id] = 2
    get :report
    assert_template 403
  end

  def setup # works like before filter
    @request.session[:user_id] = 1
  end

  def test_view_report_self
    get :view_report_self
    common_assertions_for_show_report
  end
  
  def test_show_user_report
    get :show_user_report, {id: 1}
    common_assertions_for_show_report
  end

  def common_assertions_for_show_report
    assert_response :success
    assert_template 'view_report_self'
  end

  def test_pending
    get :pending
    common_assertions_for_pending_approved_unapproved
  end
  
  def test_approved
    get :approved
    common_assertions_for_pending_approved_unapproved
  end

  def test_unapproved
    get :unapproved
    common_assertions_for_pending_approved_unapproved
  end

  def common_assertions_for_pending_approved_unapproved
    assert_response :success
    assert_template :view_more_leaves
  end

  def create_leave_attribute(type, status, start_date, end_date)
    {:leave => {:employee => type, :status => status, :leave_start_between => start_date, :leave_end_between => end_date}}
  end

  def test_report
    #definition for leave attribute and pass parameters
    get :report, {:user_id => 1 }.merge(create_leave_attribute("name_wise", "All", nil, nil))
    commoon_assertions_for_report
    get :report, {:current_designation_id => 1 }.merge(create_leave_attribute("designation_wise", "All", nil, nil))
    commoon_assertions_for_report
    get :report, {}.merge(create_leave_attribute("name_wise", "All", "2014-01-01", "2014-01-01"))
    commoon_assertions_for_report
    get :report, {}.merge(create_leave_attribute("name_wise", "Pending", nil, nil))
    commoon_assertions_for_report
    get :report, {:user_id => 1 }.merge(create_leave_attribute("name_wise", "Pending", "2014-01-01", "2014-01-01"))
    commoon_assertions_for_report
    get :report, {:current_designation_id => 1 }.merge(create_leave_attribute("designation_wise", "Pending", "201-01-01", "2014-01-01"))
    commoon_assertions_for_report
  end

  def commoon_assertions_for_report
    assert_response :success
    assert_template 'report'
  end
end
