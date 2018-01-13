class CreateTableDevices < Sequel::Migration
  def up
    create_table :barks do
      primary_key :id
      column :house_id, Integer
      column :trigger_id, Integer
      column :action_id, Integer
      column :title, String
      column :mappings, :jsonb
      column :settings, :jsonb

      column :created_at, :timestamp
      column :updated_at, :timestamp
    end
  end

  def down
    drop_table :barks
  end
end