class EntriesTags < ActiveRecord::Base
  set_table_name "entries_tags"
  belongs_to :tag
  belongs_to :entry
end
