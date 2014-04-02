require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmDesignationHistoryTest < ActiveSupport::TestCase

  def test_validate_applicable_from
    desigantion_history = SystangoHrmDesignationHistory.by_user_id(1).order_by_id_desc
    desigantion_history.first.applicable_from = "2012-02-01"
    assert_equal false, desigantion_history.first.save
    assert_equal true, desigantion_history.first.errors.has_key?(:applicable_from)
  end

  def test_leaves_entitled_during_new_designation_for_current_year
    desigantion_history = SystangoHrmDesignationHistory.by_user_id(1).order_by_id_desc
    assert_equal 16.666666666666668, desigantion_history.first.leaves_entitled_during_new_designation_for_current_year
  end

  def test_previous
    desigantion_history = SystangoHrmDesignationHistory.by_user_id(1).order_by_id_desc
    assert_equal true, desigantion_history.first.previous.is_a?(SystangoHrmDesignationHistory)
  end

  def test_next
    desigantion_history = SystangoHrmDesignationHistory.by_user_id(1).order_by_id_desc
    assert_equal true, desigantion_history.last.next.is_a?(SystangoHrmDesignationHistory)
  end

  def test_applicable_from_month
    assert_equal 3, SystangoHrmDesignationHistory.by_user_id(1).order_by_id_desc.first.applicable_from_month
  end

  def test_applicable_histories_for_current_year
    desigantion_history = SystangoHrmDesignationHistory.applicable_histories_for_current_year(1)
    desigantion_history.each do |history|
      assert_equal true, history.is_a?(SystangoHrmDesignationHistory)
    end
    assert_equal 2, desigantion_history.count
  end

end
