require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmEmployeeLeavesControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_employee_leaves, :systango_hrm_leave_accounts, :systango_hrm_request_receivers, :systango_hrm_subjects, :users, :systango_hrm_leave_summary_current_years])

  def test_require_login_filter
    @request.session[:user_id] = nil
    get :new
    assert_response 302
  end

  def test_check_leave_account_is_created_filter
    @request.session[:user_id] = 6
    ['new', 'create'].each do |action|
      get action.to_sym
      assert_response 302
    end
    ['update', 'edit'].each do |action|
      get action.to_sym, {id: 1}
      assert_response 302
    end
  end

  def test_authorize_to_view_application_filter
    @request.session[:user_id] = 6
    get :application, {id: 1}
    assert_response 302
  end

  def setup # works like before filter
    @request.session[:user_id] = 1
    @request.env['HTTP_REFERER'] = 'http://test.host/holidays'
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template 'systango_hrm_employee_leaves/create_update_leaves'
  end
  
  def test_create
    #checking successful creation of leave
    [{attrs: {apply: {leave: "self"}, receiver_id: {id: ["", "2", "3"]}, continue: "Submit and Continue", systango_hrm_employee_leave: {is_half_day: 1, leave_start_date: "2014-01-01", leave_end_date: "2014-01-01", subject_id: 1, remark: "Test Case remarks"}}, redirect: {:action => 'new'}},
     {attrs: {apply: {leave: "refer"}, receiver_id: {id: ["", "2", "3"]}, view: "Submit and View", systango_hrm_employee_leave: {referral_id: 2, leave_start_date: "2014-01-01", leave_end_date: "2014-01-01", subject_id: 1, remark: "Test Case remarks"}}, redirect: {:controller => "systango_hrm_employee_leaves", :action => 'manage_request'}},
     {attrs: {apply: {leave: "self"}, receiver_id: {id: ["", "2", "3"]}, view: "Submit and View", systango_hrm_employee_leave: {leave_start_date: "2014-01-01", leave_end_date: "2014-01-01", subject_id: 1, remark: "Test Case remarks"}}, redirect: {:controller => "systango_hrm_leave_reports", :action => 'view_report_self'}}
    ].each do |params|
      post :create, params[:attrs]
      employee_leave = SystangoHrmEmployeeLeave.last
      assert_redirected_to params[:redirect]
      assert_equal employee_leave, assigns(:employee_leave)
    end

    #checking rendering when validation failed
    post :create, {apply: {leave: "self"}, receiver_id: {id: ["", "2", "3"]}, continue: "Submit and Continue", systango_hrm_employee_leave: {is_half_day: 1, leave_start_date: "2014-01-01", leave_end_date: "2014-01-01", subject_id: 1, remark: nil}}
    assert_equal true, assigns(:employee_leave).errors.has_key?(:remark)
    assert_template 'create_update_leaves'
  end

  def test_update_leave_status
    post :update_leave_status, {id: 1, unapprove: "Unapprove", systango_hrm_employee_leave: {comment: "Okay"}}
    request_reciever = SystangoHrmRequestReceiver.first
    assert_equal request_reciever, assigns(:request_reciever)
  end
  
  def test_edit
    get :edit, {id: 1}
    assert_response :success
    assert_template 'systango_hrm_employee_leaves/create_update_leaves'
  end

  def test_update
    #checking successful updation of leave.
    [{id: 2, apply: {leave: "refer"}, receiver_id: {id: ["", "2", "3"]}, systango_hrm_employee_leave: {leave_start_date: "2014-01-01", leave_end_date: "2014-01-01", subject_id: 1, remark: "Test Case remarks", referral_id: 1}},
     {id: 3, continue: "Continue", apply: {leave: "refer"}, systango_hrm_employee_leave: {leave_start_date: "2014-01-01", leave_end_date: "2014-01-02", subject_id: 1, remark: "Test Case remarks"}}
    ].each do |params|
      put :update, params
      employee_leave = SystangoHrmEmployeeLeave.find(params[:id])
      if params[:continue].blank?
        assert_redirected_to  :controller => "systango_hrm_leave_reports", :action => 'view_report_self'
      else
        assert_template 'systango_hrm_employee_leaves/create_update_leaves'
      end
      assert_equal employee_leave.reload, assigns(:employee_leave)
    end

    #checking rendering when validations failed.
    put :update, {id: 2, apply: {leave: "refer"}, receiver_id: {id: ["", "2", "3"]}, systango_hrm_employee_leave: {leave_start_date: "2014-01-01", leave_end_date: "2014-01-01", subject_id: nil, remark: "Test Case remarks", referral_id: 1}}
    assert_equal true, assigns(:employee_leave).errors.has_key?(:subject_id)
    assert_template 'create_update_leaves'
  end

  def test_application
    get :application, {id: 1}
    assert_response :success
    assert_template 'application'
  end

  def test_manage_request
    get :manage_request
    assert_response :success
    assert_template :manage_request
  end
  
  def assert_status
    assert_response :success
    assert_template :more_leaves
  end

  def test_pending
    get :pending
    assert_status
  end
  
  def test_approved
    get :approved
    assert_status
  end
  
  def test_unapproved
    get :unapproved
    assert_status
  end

end