require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmDesignationTest < ActiveSupport::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_designations, :users])

  def test_validate_leaves_entitled
    designation = SystangoHrmDesignation.new
    designation.designation = "Level01"

    [nil, 0.4, -1, 0].each do |value|
      designation.leaves_entitled = value
      assert_equal false, designation.valid?
      assert_equal true, designation.errors.has_key?(:leaves_entitled)
    end
  end

end
