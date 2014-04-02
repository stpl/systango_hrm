class CreateSystangoHrmDesignationHistories < ActiveRecord::Migration
  def change
    create_table :systango_hrm_designation_histories do |t|
      t.integer :user_id
			t.integer :prev_designation_id
      t.integer :new_designation_id
      t.date :applicable_from
      t.string :remarks
      t.timestamps
    end
    add_index "systango_hrm_designation_histories", ["user_id"]
    add_index "systango_hrm_designation_histories", ["prev_designation_id"]
    add_index "systango_hrm_designation_histories", ["new_designation_id"]
  end
end
