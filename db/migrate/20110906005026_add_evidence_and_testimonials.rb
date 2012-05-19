class AddEvidenceAndTestimonials < ActiveRecord::Migration
  def self.up
    create_table :evidence, :options => "DEFAULT CHARSET=utf8" do |t|
      t.integer :entry_id, :null => false
      t.string :url
      t.timestamps
    end

    add_index :evidence, :entry_id

    create_table :testimonials, :options => "DEFAULT CHARSET=utf8" do |t|
      t.integer :entry_id, :null => false
      t.integer :user_id, :null => false
      t.string :text
      t.boolean :confirmed, :default => false
      t.timestamps
    end

    add_index :testimonials, :entry_id
    add_index :testimonials, :user_id
  end

  def self.down
    drop_table :evidence
    drop_table :testimonials
  end
end
