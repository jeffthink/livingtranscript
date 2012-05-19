class AddUserType < ActiveRecord::Migration
  def self.up
    add_column :users, :user_type, :string, :null => false
  end

  def self.down
    remove_column :users, :user_type
  end
end
