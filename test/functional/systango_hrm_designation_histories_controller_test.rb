require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmDesignationHistoriesControllerTest < ActionController::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_designations,:systango_hrm_designation_histories,:systango_hrm_leave_accounts,:systango_hrm_leave_summary_current_years, :users])

  def setup # works like before filter
    @request.session[:user_id] = 1
  end

  def test_update
    #have to test 3 case here, thats why calling update 3 times (viz - only designation, only date, date and designatoin both)
    # updating the old records
    [{user_id: 3, attrs: {designation_id: 3, designation_history: {applicable_from: "2014-02-01", remarks: "update designation"},id: 3}},
    {user_id: 1, attrs: {designation_id: 3, designation_history: {applicable_from: "2014-04-12", remarks: "update date only"},id: 1}}
    ].each do |params|
      record = SystangoHrmDesignationHistory.where(user_id: params[:user_id]).last
      put :update, params[:attrs]
      assert_equal record.reload, assigns(:designation_history)
    end
    #creating a new record
    put :update  ,{ designation_id: 3, designation_history: {applicable_from: "2014-02-12", remarks: "update both"},id: 2}
    record = SystangoHrmDesignationHistory.where(new_designation_id: 3, user_id: 2).last
    assert_equal record, assigns(:designation_history)

    put :update  ,{ designation_id: 3, designation_history: {applicable_from: "20-2014-1023", remarks: "update both"},id: 2}
    assert_template 'systango_hrm_employees/edit'
  end

  def test_validate_field_without_promotion_filter
      put :update, {designation_id: 1, designation_history: {applicable_from: "20-2014-1023", remarks: "update designation"},id: 4}
      assert_template 'systango_hrm_employees/edit'

      put :update, {designation_id: 1, designation_history: {applicable_from: "2014-02-01", remarks: "update designation"},id: 4}
      assert_template 'systango_hrm_employees/edit'

      put :update, {designation_id: 2, designation_history: {applicable_from: "2014-01-01", remarks: "update designation"},id: 4}
      assert_template 'systango_hrm_employees/edit'
  end
end
