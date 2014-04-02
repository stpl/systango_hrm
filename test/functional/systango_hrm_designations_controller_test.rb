require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmDesignationsControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_designations, :users])

  def test_require_login_filter
    @request.session[:user_id] = nil
    get :index
    assert_response 302
  end

  def setup # works like before filter
    @request.session[:user_id] = 1
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end
  
  def test_create
    #checked successful creation of designation record
    post :create, :designation => {designation: "Level05", leaves_entitled: 25}
    designation = SystangoHrmDesignation.where(:designation => "Level05", :leaves_entitled => "25").first
    assert_equal designation, assigns(:designation)

    #checked rendering when valildation failed
    post :create, :designation => {designation: "Level05", leaves_entitled: nil}
    assert_equal true, assigns(:designation).errors.has_key?(:leaves_entitled)
    assert_template 'index'
  end
  
  def test_edit
    designation = SystangoHrmDesignation.find(1)
    get :edit, :id => designation
    assert_template 'edit'
  end

  def test_update
    #checked successful updation of designation record
    designation = SystangoHrmDesignation.find(1)
    # required two times id because one for route and another for params
    put :update, id: designation, :designation => {designation: 'Level04', leaves_entitled: designation.leaves_entitled, id: designation}
    designation = SystangoHrmDesignation.where(:designation => "Level04", :leaves_entitled => "16").first
    assert_equal designation.reload, assigns(:designation)

    #checked rendering when valildation failed
    put :update, id: designation, :designation => {designation: 'Level04', leaves_entitled: nil, id: designation}
    assert_equal true, assigns(:designation).errors.has_key?(:leaves_entitled)
    assert_template 'edit'
  end
  
  def test_context_menu
    get :context_menu, {selected_designations: ["1"]} 
    assert_response :success
    assert_template :context_menu
  end
end