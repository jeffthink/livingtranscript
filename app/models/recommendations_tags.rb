class RecommendationsTags < ActiveRecord::Base
  set_table_name "recommendations_tags"
  belongs_to :tag
  belongs_to :recommendation
end
