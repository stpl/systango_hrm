require File.expand_path('../../test_helper', __FILE__)

class SystangoHrmTeamleadsSubordinatesTest < ActiveSupport::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', [:systango_hrm_teamleads_subordinates, :systango_hrm_leave_accounts, :users])
  
  def test_unlocked_subordinates_for
    users = SystangoHrmTeamleadsSubordinates.unlocked_subordinates_for(SystangoHrmTeamleadsSubordinates.by_teamlead_user_id(1).to_a)
    assert_equal true, users.all?{|user| [User.find(2), User.find(3)].include? user}
  end  
  
  def test_unlocked_teamleads_for
    users = SystangoHrmTeamleadsSubordinates.unlocked_teamleads_for(SystangoHrmTeamleadsSubordinates.by_subordinate_user_id(3).to_a)
    assert_equal true, users.all?{|user| [User.find(2), User.find(1)].include? user}
  end  

  def test_mails_delivered_on_subordinate_add_or_remove
    teamlead_subordinate = SystangoHrmTeamleadsSubordinates.create(:teamlead_user_id => 2, :subordinate_user_id => 4)
    assert_equal true, teamlead_subordinate.is_a?(SystangoHrmTeamleadsSubordinates)
    assert_equal 3, Delayed::Job.count

    SystangoHrmTeamleadsSubordinates.find(1).destroy
    assert_equal 6, Delayed::Job.count
  end

end
