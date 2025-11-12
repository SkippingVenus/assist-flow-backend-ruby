class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    
    create_table :companies, id: :uuid do |t|
      t.string :name, null: false
      t.time :work_start_time, default: '08:00:00'
      t.time :work_end_time, default: '17:00:00'
      t.integer :late_threshold_minutes, default: 15

      t.timestamps
    end
    
    add_index :companies, :name
  end
end
