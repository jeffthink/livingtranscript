class Recommendation < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  has_many :tags, :through => :recommendations_tags, :class_name => "Tag"
  has_many :recommendations_tags, :class_name => "RecommendationsTags"
  has_many :evidence, :dependent => :destroy, :class_name => "RecommendationEvidence"

  STATUS_NEW = "NEW"
  STATUS_PENDING_APPROVAL = "PENDING_APPROVAL"
  STATUS_CONFIRMED = "CONFIRMED"
  STATUS_DENIED = "DENIED"

  RECOMMENDATION_STATUSES = [
    STATUS_NEW,
    STATUS_PENDING_APPROVAL,
    STATUS_CONFIRMED ,
    STATUS_DENIED
  ]


  validates_inclusion_of :status, :in => RECOMMENDATION_STATUSES, :allow_nil => false, :allow_blank => false


  def build_tags(tags)
    if tags && tags.length > 0
      parts = tags.split(",")
      parts.each do |t|
        tag = Tag.find_by_name(t)
        self.tags << tag if tag && !self.tags.include?(tag)
      end
    end
  end

  def notify_entry_user!(request)
    Mailer.recommendation_notification({:recommendation_user => self.user,
                                         :entry_user => self.entry.user,
                                         :request => request }).deliver
  end

  def self.count_confirmed
    find_all_by_status(Recommendation::STATUS_CONFIRMED).count
  end

  def build_evidences(evidence)
    if evidence && evidence != ""
      self.evidence << RecommendationEvidence.new(:url => evidence)
    end
  end

  def text_summary
    ts = self.text
    if ts && ts.length > 255
      ts = "#{ts[0..254]}..."
    end
    ts
  end
end
