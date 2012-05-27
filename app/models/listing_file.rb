class ListingFile < ActiveRecord::Base
  attr_accessible :email_count, :file_checksum, :file_name, :file_path, :file_size, :has_changed, :still_exist
end
