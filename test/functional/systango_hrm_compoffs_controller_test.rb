require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmCompoffsControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_compoffs, :systango_hrm_leave_accounts, :systango_hrm_leave_summary_current_years, :users])

  def test_require_login_filter
    @request.session[:user_id] = nil
    get :new
    assert_response 302
  end

  def setup # works like before filter
    @request.session[:user_id] = 1
    @request.env['HTTP_REFERER'] = 'http://test.host/holidays'
  end
    
  def test_new
    get :new
    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:users)
    users = SystangoHrmLeaveAccount.with_active_user.map(&:user).compact.sort_by(&:firstname)
    assert_equal users, assigns(:users)
  end
  
  def test_create
    #created compoff with correct values
    post :create, user_id: 1, commit: "Submit", compoff: { comp_off_given: 1, comp_off_remarks: "Test remarsk3"}
    compoff = SystangoHrmCompoff.where(:user_id => 1, :comp_off_given => 1, :comp_off_remarks => "Test remarsk3").first
    assert_equal compoff, assigns(:compoff)
    assert_redirected_to :action => 'new'

    #checked rendering when form is submitted via javascript
    post :create, user_id: 1
    compoffs = User.find(1).systango_hrm_compoffs.order_by_created_desc rescue nil
    assert_equal compoffs, assigns(:compoffs)
    assert_template 'new'

    #checked rendering when validatoins failed
    post :create, user_id: 1, commit: "Submit", compoff: { comp_off_remarks: "Test remarsk3"}
    assert_equal true, assigns(:compoff).errors.has_key?(:comp_off_given)
    assert_template 'new'
  end

end