class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :post_id
      t.integer :bio_id

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
