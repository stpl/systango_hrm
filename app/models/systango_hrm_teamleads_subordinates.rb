class SystangoHrmTeamleadsSubordinates < SystangoHrmModel
  unloadable

  has_one :subordinate_leave_account, :foreign_key => 'subordinate_user_id', :class_name => "SystangoHrmLeaveAccount"
  has_one :teamlead_leave_account, :foreign_key => 'teamlead_user_id', :class_name => "SystangoHrmLeaveAccount"
  belongs_to :teamlead_user, :class_name => "User", :foreign_key => 'teamlead_user_id'
  belongs_to :subordinate_user, :class_name => "User", :foreign_key => 'subordinate_user_id'

  scope :by_subordinate_user_id, ->(user_id) { where(subordinate_user_id: user_id) }
  scope :by_teamlead_user_id, ->(user_id) { where(teamlead_user_id: user_id) }
  scope :by_teamlead_and_subordinate_user_id, ->(teamlead_id, subordinate_id) { where(teamlead_user_id: teamlead_id, subordinate_user_id: subordinate_id) }

  class << self
    def unlocked_subordinates_for(teamleads = [])
    	return unless teamleads.is_a?(Array)
    	(teamleads.collect{|teamlead| teamlead.subordinate_user if teamlead.subordinate_user.status != SystangoHrm::Constants::STATUS_LOCKED }).compact
  	end

    def unlocked_teamleads_for(subordinates = [])
    	return unless subordinates.is_a?(Array)
    	(subordinates.collect{|subordinate| subordinate.teamlead_user if subordinate.teamlead_user != SystangoHrm::Constants::STATUS_LOCKED }).compact
    end

  end
end
