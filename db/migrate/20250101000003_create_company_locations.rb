class CreateCompanyLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :company_locations, id: :uuid do |t|
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :latitude, precision: 10, scale: 8, null: false
      t.decimal :longitude, precision: 11, scale: 8, null: false
      t.integer :radius_meters, default: 100

      t.timestamps
    end
    
    add_index :company_locations, [:latitude, :longitude]
  end
end
