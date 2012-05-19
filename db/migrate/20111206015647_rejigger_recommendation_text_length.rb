class RejiggerRecommendationTextLength < ActiveRecord::Migration
  def self.up
    change_column :recommendations, :text, :text
  end

  def self.down
  end
end
