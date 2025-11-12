class CreateVacationRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :vacation_requests, id: :uuid do |t|
      t.references :employee, type: :uuid, null: false, foreign_key: true
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.text :reason
      t.integer :status, default: 0 # 0: pending, 1: approved, 2: rejected
      t.datetime :reviewed_at
      t.uuid :reviewed_by_id

      t.timestamps
    end
    
    add_index :vacation_requests, :status
    add_index :vacation_requests, [:employee_id, :start_date]
  end
end
