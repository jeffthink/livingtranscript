class RenameTestimonials < ActiveRecord::Migration
  def self.up
    rename_table :testimonials, :recommendations
  end

  def self.down
    rename_table :recommendations, :testimonials
  end
end
