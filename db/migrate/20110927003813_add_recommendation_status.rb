class AddRecommendationStatus < ActiveRecord::Migration
  def self.up
    remove_column :recommendations, :confirmed
    add_column :recommendations, :status, :string, :default => Recommendation::STATUS_NEW
    add_column :recommendations, :feedback, :string
    add_column :recommendations, :relationship, :string
    create_table :recommendations_tags, :id => false, :options => "DEFAULT CHARSET=utf8" do |t|
      t.integer :recommendation_id
      t.integer :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations_tags
    remove_column :recommendations, :relationship
    remove_column :recommendations, :feedback
    remove_column :recommendations, :status
    add_column :recommendations, :confirmed, :boolean, :default => false
  end
end
