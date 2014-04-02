class SystangoHrmTeamleadsSubordinatesObserver < ActiveRecord::Observer

  def after_create(teamlead_subordinate)
    SystangoHrmMailer.delay.notify_subordinate_of_tl_updation(find_existing_teamleads(teamlead_subordinate), teamlead_and_subordinate_id(teamlead_subordinate), is_added=true)
    SystangoHrmMailer.delay.notify_tl_of_subordinate_updation(teamlead_and_subordinate_id(teamlead_subordinate), for_admin = false, is_subordinate_added=true)
    SystangoHrmMailer.delay.notify_tl_of_subordinate_updation(teamlead_and_subordinate_id(teamlead_subordinate), for_admin = true, is_subordinate_added=true)
  end
 
  def after_destroy(teamlead_subordinate)
    SystangoHrmMailer.delay.notify_subordinate_of_tl_updation(find_existing_teamleads(teamlead_subordinate), teamlead_and_subordinate_id(teamlead_subordinate), is_added=false)
    SystangoHrmMailer.delay.notify_tl_of_subordinate_updation(teamlead_and_subordinate_id(teamlead_subordinate), for_admin = false, is_subordinate_added=false)
    SystangoHrmMailer.delay.notify_tl_of_subordinate_updation(teamlead_and_subordinate_id(teamlead_subordinate), for_admin = true, is_subordinate_added=false)
  end

  def find_existing_teamleads(teamlead_subordinate)
    teamlead_subordinate = (SystangoHrmTeamleadsSubordinates.by_subordinate_user_id(teamlead_subordinate.subordinate_user_id) rescue []) - [teamlead_subordinate]
    SystangoHrmTeamleadsSubordinates.unlocked_teamleads_for(teamlead_subordinate)
  end

  def teamlead_and_subordinate_id(teamlead_subordinate)
    #Lakhan : Need to send it because after destroy these id's are not available.
    { teamlead_id: teamlead_subordinate.teamlead_user_id, subordinate_id: teamlead_subordinate.subordinate_user_id }
  end

end