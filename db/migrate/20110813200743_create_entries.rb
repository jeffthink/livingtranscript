class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries, :options => "DEFAULT CHARSET=utf8" do |t|
      t.integer :user_id, :null => false
      t.string :title, :null => false
      t.text :reflection, :null => false
      t.timestamps
    end

    add_index :entries, :user_id
  end

  def self.down
    drop_table :entries
  end
end
