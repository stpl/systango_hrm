require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmTeamleadsControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_teamleads_subordinates, :users])

  def test_require_login_filter
    @request.session[:user_id] = nil
    ['subordinates', 'teamleads_subordinates'].each do |action|
      get action.to_sym
      assert_response 302
    end
  end

  def setup # works like before filter
    @request.session[:user_id] = 1
  end

  def test_validate_subordinates_filter
    post :add_or_remove_subordinates, {add: "Add", teamlead_subordinate: {teamlead_id: 3}}
    assert_response 302

    post :add_or_remove_subordinates, {remove: "Remove", teamlead_subordinate: {teamlead_id: 1}}
    assert_response 302
  end

  def test_subordinates
    get :subordinates
    common_assertiond_for_show_and_subordinates
  end
  
  def test_show
    post :show, {teamlead_user_id: 1}
    assert_not_nil assigns(:non_subordinates)
  end

  def common_assertiond_for_show_and_subordinates
    assert_response :success
    assert_not_nil assigns(:employees)
    assert_template 'subordinates'
  end

  def test_add_or_remove_subordinates
    post :add_or_remove_subordinates, {add: "Add", teamlead_subordinate: {teamlead_id: 3}, non_subordinate: {user_ids: ["5"]}}
    teamlead_subordinate = SystangoHrmTeamleadsSubordinates.where(:teamlead_user_id  => 3, :subordinate_user_id => 5).first
    #checked not_nil here because we are not creating any instance in controller.
    assert_not_nil true, teamlead_subordinate

    post :add_or_remove_subordinates, {remove: "Remove", teamlead_subordinate: {teamlead_id: 1}, subordinate: {user_ids: ["3"]}}
    teamlead_subordinate = SystangoHrmTeamleadsSubordinates.where(:teamlead_user_id  => 1, :subordinate_user_id => 3).first
    assert_nil teamlead_subordinate
  end
  
  def test_teamleads_subordinates
    get :teamleads_subordinates
    common_assertion_for_show_teamleads_subordinates_and_teamleads_subordinates
  end
  
  def test_show_teamleads_subordinates
    post :show_teamleads_subordinates, {user_id: 1}
    common_assertion_for_show_teamleads_subordinates_and_teamleads_subordinates
  end

  def common_assertion_for_show_teamleads_subordinates_and_teamleads_subordinates
    assert_response :success
    assert_not_nil assigns(:employees)
    assert_template 'teamleads_subordinates'
  end

  def test_autocomplete_subordinates
    get :autocomplete_subordinates, {q: "a", format: "1"}
    common_assertions_for_autocomplete_subordinates_and_autocomplete_teamleads
  end
  
  def test_autocomplete_teamleads
    get :autocomplete_teamleads, {q: "a", format: "1"}
    common_assertions_for_autocomplete_subordinates_and_autocomplete_teamleads
  end

  def common_assertions_for_autocomplete_subordinates_and_autocomplete_teamleads
    assert_response :success
    assert_template 'systango_hrm_teamleads/autocomplete'
  end

end
