class CreateSystangoHrmEmployeeLeaves < ActiveRecord::Migration
  def change
    create_table :systango_hrm_employee_leaves do |t|
      t.integer :user_id
      t.integer :referral_id
      t.boolean :is_half_day, :default => false
      t.boolean :is_maternity_leave, :default => false
      t.datetime :leave_start_date
      t.datetime :leave_end_date
      t.integer :subject_id
      t.string :remark
      t.string :status, :default => "pending"
      t.timestamps
    end
    add_index "systango_hrm_employee_leaves", ["user_id"]
    add_index "systango_hrm_employee_leaves", ["referral_id"]
  end
end
