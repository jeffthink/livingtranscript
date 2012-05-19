class CreateTagsTable < ActiveRecord::Migration
  def self.up
    create_table :tags, :options => "DEFAULT CHARSET=utf8" do |t|
      t.string :name
      t.timestamps
    end

    create_table :entries_tags, :id => false, :options => "DEFAULT CHARSET=utf8" do |t|
      t.integer :entry_id
      t.integer :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :entries_tags
    drop_table :tags
  end
end
