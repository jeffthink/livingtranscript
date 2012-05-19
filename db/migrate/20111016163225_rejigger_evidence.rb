class RejiggerEvidence < ActiveRecord::Migration
  def self.up
    rename_table :evidence, :entry_evidence

    create_table :recommendation_evidence, :options => "DEFAULT CHARSET=utf8" do |t|
      t.integer :recommendation_id, :null => false
      t.string :url
      t.timestamps
    end
  end

  def self.down
    drop_table :recommendation_evidence
    rename_table :entry_evidence, :evidence
  end
end
