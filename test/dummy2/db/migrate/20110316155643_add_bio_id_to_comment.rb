class AddBioIdToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :bio_id, :integer
  end

  def self.down
    remove_column :comments, :bio_id
  end
end
