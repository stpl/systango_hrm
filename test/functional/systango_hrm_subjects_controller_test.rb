require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmSubjectsControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_subjects, :users])

  def test_require_login_filter
    @request.session[:user_id] = nil
    get :new
    assert_response 302
  end

  def setup
    @request = ActionController::TestRequest.new
    @request.env['HTTP_REFERER'] = 'http://test.host/subjects/new'
    @request.session[:user_id] = 1
  end

  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    subjects = SystangoHrmSubject.all_as_array
    assert_not_nil assigns(:subjects)
    assert_equal subjects, assigns(:subjects)
  end
  
  def test_create
    #created subject with correct values
    post :create, subject: {subject: "tests"}
    subject = SystangoHrmSubject.where(:subject => "tests").first
    assert_redirected_to :controller => 'systango_hrm_subjects', :action => 'new'
    assert_equal subject, assigns(:subject)

    #checked rendering when validatoins failed
    post :create, subject: {subject: nil}
    assert_equal true, assigns(:subject).errors.has_key?(:subject)
    assert_template 'new'
  end
  
  def test_edit
    subject = SystangoHrmSubject.find(1)
    get :edit, id: subject
    assert_template 'edit'
    assert_not_nil assigns(:subject)
  end
  
  def test_update
    #updating subject with correct values
    subject = SystangoHrmSubject.find(1)
    put :update, id: subject, subject: {subject: 'Out of station'}
    assert_equal subject.reload, assigns(:subject)

    #checked rendering when validatoins failed
    post :update, id: subject, subject: {subject: nil}
    assert_equal true, assigns(:subject).errors.has_key?(:subject)
    assert_template 'edit'
  end
  
  def test_context_menu
    get :context_menu, {selected_subjects: ["1"]}
    assert_response :success
    assert_template :context_menu
  end
end
