class AddUuidToTestimonials < ActiveRecord::Migration
  def self.up
    add_column :testimonials, :uuid, :string, :null => false

    add_index :testimonials, :uuid, :unique => true
  end

  def self.down
    remove_column :testimonials, :uuid
  end
end
