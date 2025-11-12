class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles, id: :uuid do |t|
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name, null: false

      t.timestamps
    end
    
    add_index :profiles, :email, unique: true
    add_index :profiles, [:company_id, :email], unique: true
  end
end
