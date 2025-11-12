class CreatePayrollCalculations < ActiveRecord::Migration[7.1]
  def change
    create_table :payroll_calculations, id: :uuid do |t|
      t.references :employee, type: :uuid, null: false, foreign_key: true
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.integer :total_days_worked, default: 0
      t.integer :total_hours_worked, default: 0
      t.integer :overtime_hours, default: 0
      t.integer :late_days, default: 0
      t.integer :total_late_minutes, default: 0
      t.decimal :base_salary, precision: 10, scale: 2
      t.decimal :overtime_pay, precision: 10, scale: 2, default: 0
      t.decimal :bonus, precision: 10, scale: 2, default: 0
      t.decimal :deductions, precision: 10, scale: 2, default: 0
      t.decimal :total_earnings, precision: 10, scale: 2
      t.decimal :net_pay, precision: 10, scale: 2
      t.text :notes

      t.timestamps
    end
    
    add_index :payroll_calculations, [:employee_id, :period_start]
    add_index :payroll_calculations, :period_start
    add_index :payroll_calculations, :period_end
  end
end
