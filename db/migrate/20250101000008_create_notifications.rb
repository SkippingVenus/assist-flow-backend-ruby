class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :employee, type: :uuid, foreign_key: true
      t.uuid :recipient_id, null: false
      t.string :recipient_type, null: false
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :message
      t.jsonb :data
      t.boolean :is_read, default: false

      t.timestamps
    end
    
    add_index :notifications, [:recipient_type, :recipient_id]
    add_index :notifications, :is_read
    add_index :notifications, :notification_type
    add_index :notifications, :created_at
  end
end
