require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmEmployeesControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_leave_accounts, :systango_hrm_designation_histories, :systango_hrm_leave_summary_current_years, :users])

  def test_require_login_filter
    @request.session[:user_id] = nil
    get :add_details
    assert_response 302
  end

  def setup # works like before filter
    @request.session[:user_id] = 1
  end
  
  def test_add_details
    get :add_details
    assert_response :success
    assert_template 'add_details'
    assert_not_nil assigns(:users_not_having_leave_account)
    assert_not_nil assigns(:users_having_leave_account)
    assert_not_nil assigns(:designations)
  end
  
  def test_create_leave_account
    #checking creation updation of leave_account
    post :create_leave_account, {designation_id: 1, record: {employee: "not_have_account", user_id: ["","6"], users_id: [""], date_of_joining: "2014-01-01", maternity_leave: 0, remarks: "Designation Added"}}
    leave_account = SystangoHrmLeaveAccount.where(:user_id => 6, :current_designation_id => 1, :date_of_joining => "2014-01-01".to_date).first
    assert_equal leave_account, assigns(:leave_account)

    #checking rendering when validations failed
    post :create_leave_account, {designation_id: 1, record: {employee: "not_have_account", user_id: ["","6"], users_id: [""], date_of_joining: "2014-01-01", maternity_leave: 0, remarks: nil}}
    assert_equal true, assigns(:leave_account).errors.has_key?(:remarks)
    assert_template 'add_details'
  end

  def test_edit
    leave_account = SystangoHrmLeaveAccount.find(4)
    get :edit, :id => leave_account
    assert_template 'edit'
    common_assertions_for_edit_and_update
  end

  def test_update
    #checking successful updation of leave_account
    leave_account = SystangoHrmLeaveAccount.find(4)
    put :update,{employee_leave_account: {date_of_joining: "2014-02-01", maternity_leave: 1}, designation_id: 2, id: 4}
    leave_account = SystangoHrmLeaveAccount.where(:user_id => 4, :current_designation_id => 2, :date_of_joining => "2014-02-01").first
    assert_equal leave_account, assigns(:leave_account)
    common_assertions_for_edit_and_update

    #checking rendering when validations failed
    put :update,{employee_leave_account: {date_of_joining: nil, maternity_leave: 1}, designation_id: 2, id: 4}
    assert_equal true, assigns(:leave_account).errors.has_key?(:date_of_joining)
    assert_template 'edit'
  end

  def common_assertions_for_edit_and_update
    assert_not_nil assigns(:designation_histories)
    assert_not_nil assigns(:designation_history)
    assert_not_nil assigns(:leave_account)
  end

  def test_context_menu
    get :context_menu , {selected_leave_accounts: ["1"]} 
    assert_response :success
    assert_template :context_menu
    assert_not_nil assigns(:leave_account)
    assert_not_nil assigns(:leave_accounts)
  end

end
