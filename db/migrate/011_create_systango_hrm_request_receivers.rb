class CreateSystangoHrmRequestReceivers < ActiveRecord::Migration
  def change
    create_table :systango_hrm_request_receivers do |t|
      t.integer :application_id
      t.integer :receiver_id
      t.string :comment
      t.string :receiver_approval_status, :default => "pending"
      t.timestamps
    end
    add_index "systango_hrm_request_receivers", ["application_id"]
    add_index "systango_hrm_request_receivers", ["receiver_id"]
  end
end
