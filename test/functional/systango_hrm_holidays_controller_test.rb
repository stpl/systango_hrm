require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmHolidaysControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_holidays, :users])

  def test_require_login_filter
    @request.session[:user_id] = nil
    get :index
    assert_response 302
  end

  def setup # works like before filter
    @request.session[:user_id] = 1
    @request.env['HTTP_REFERER'] = 'http://test.host/holidays'
  end
    
  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:holiday)
  end
  
  def test_create
    post :create, holiday: {holiday_date: Date.today, holiday_for: "test holiday"}
    holiday = SystangoHrmHoliday.where(:holiday_date => Date.today, :holiday_for => "test holiday").first
    assert_equal holiday, assigns(:holiday)

    post :create, holiday: {holiday_date: "2014-03-28", holiday_for: nil}
    assert_equal true, assigns(:holiday).errors.has_key?(:holiday_for)
    assert_template 'index'
  end

  def test_edit
    holiday = SystangoHrmHoliday.find(1)
    get :edit, id: holiday
    assert_not_nil assigns(:holiday)
    assert_template 'edit'
  end
  
  def test_update
    holiday = SystangoHrmHoliday.find(3)
    # required two times id because one for route and another for params
    put :update, id: holiday, holiday: {holiday_for: '31st Dec', holiday_date: holiday.holiday_date, id: holiday}
    assert_equal holiday.reload, assigns(:holiday)

    put :update, id: holiday, holiday: {holiday_for: '31st Dec', holiday_date: nil, id: holiday}
    assert_equal true, assigns(:holiday).errors.has_key?(:holiday_date)
    assert_template 'edit'
  end
  
  def test_context_menu
    get :context_menu, {selected_holidays: ["1"]}
    assert_response :success
    assert_template :context_menu
  end
end
