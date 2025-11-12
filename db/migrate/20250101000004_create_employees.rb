class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees, id: :uuid do |t|
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :dni, null: false
      t.string :phone
      t.string :email
      t.string :job_position
      t.decimal :salary, precision: 10, scale: 2
      t.string :pin_hash, null: false
      t.string :password_digest, null: false
      t.boolean :is_active, default: true

      t.timestamps
    end
    
    add_index :employees, [:company_id, :dni], unique: true
    add_index :employees, :is_active
  end
end
