class CreateAttendanceRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :attendance_records, id: :uuid do |t|
      t.references :employee, type: :uuid, null: false, foreign_key: true
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.integer :attendance_type, null: false # 0: entrance, 1: exit, 2: lunch_start, 3: lunch_end
      t.datetime :timestamp, null: false
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.date :record_date, null: false
      t.boolean :is_late, default: false
      t.integer :minutes_late, default: 0
      t.text :notes

      t.timestamps
    end
    
    add_index :attendance_records, :record_date
    add_index :attendance_records, :timestamp
    add_index :attendance_records, [:employee_id, :record_date]
    add_index :attendance_records, :is_late
    add_index :attendance_records, :attendance_type
  end
end
