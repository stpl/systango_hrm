class CreateSystangoHrmHolidays < ActiveRecord::Migration
  def change
    create_table :systango_hrm_holidays do |t|
      t.date :holiday_date
      t.string :holiday_for
    end
  end
end
