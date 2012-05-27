class CreateListingFiles < ActiveRecord::Migration
  def change
    create_table :listing_files do |t|
      t.string :file_path
      t.string :file_name
      t.integer :file_size
      t.boolean :has_changed
      t.string :file_checksum
      t.boolean :still_exist
      t.integer :email_count

      t.timestamps
    end
  end
end
