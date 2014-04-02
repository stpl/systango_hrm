class CreateSystangoHrmCompoffs < ActiveRecord::Migration
  def change
    create_table :systango_hrm_compoffs do |t|
      t.integer :user_id
      t.decimal :comp_off_given, :default => 0.0, :precision => 10, :scale => 2
      t.string :comp_off_remarks
      t.timestamps
    end
    add_index "systango_hrm_compoffs", ["user_id"]
  end
end
