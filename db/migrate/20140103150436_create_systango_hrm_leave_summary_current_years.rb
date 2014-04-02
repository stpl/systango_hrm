class CreateSystangoHrmLeaveSummaryCurrentYears < ActiveRecord::Migration
  def change
    create_table :systango_hrm_leave_summary_current_years do |t|
      t.integer :user_id
			t.decimal :leaves_entitled, :precision => 10, :scale => 2
      t.decimal :leaves_taken, :precision => 10, :scale => 2
      t.decimal :total_comp_off_provided, :precision => 10, :scale => 2
      t.timestamps
    end
    add_index "systango_hrm_leave_summary_current_years", ["user_id"]
  end
end
