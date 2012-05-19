class RecommendationEvidence < ActiveRecord::Base
  set_table_name("recommendation_evidence")

  belongs_to :recommendation

  before_save :format_url

  private

  def format_url
    self.url = "http://#{self.url}" if (!self.url.include?("http://") && !self.url.include?("https://"))
  end
end