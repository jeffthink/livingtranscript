class EntryEvidence < ActiveRecord::Base
  set_table_name("entry_evidence")

  belongs_to :entry

  before_save :format_url

  private

  def format_url
    self.url = "http://#{self.url}" if (!self.url.include?("http://") && !self.url.include?("https://"))
  end
end