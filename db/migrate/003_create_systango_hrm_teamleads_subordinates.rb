class CreateSystangoHrmTeamleadsSubordinates < ActiveRecord::Migration
  def change
    create_table :systango_hrm_teamleads_subordinates do |t|
      t.integer :teamlead_user_id
      t.integer :subordinate_user_id
      t.timestamps
    end
    add_index "systango_hrm_teamleads_subordinates", ["teamlead_user_id"]
    add_index "systango_hrm_teamleads_subordinates", ["subordinate_user_id"]
  end
end
