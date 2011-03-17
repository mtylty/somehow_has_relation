class CreateBios < ActiveRecord::Migration
  def self.up
    create_table :bios do |t|
      t.integer :author_id

      t.timestamps
    end
  end

  def self.down
    drop_table :bios
  end
end
