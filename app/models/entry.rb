class Entry < ActiveRecord::Base
  belongs_to :user
  has_many :entries_tags, :class_name => "EntriesTags"
  has_many :tags, :through => :entries_tags, :class_name => "Tag"
  has_many :evidence, :dependent => :destroy, :class_name => "EntryEvidence"
  has_many :recommendations_tags, :class_name => "RecommendationsTags", :through => :recommendations
  has_many :recommendation_tags, :class_name => "Tag", :through => :recommendations_tags
  has_many :recommendations, :dependent => :destroy do
    def pending
      find_all_by_status(Recommendation::STATUS_PENDING_APPROVAL)
    end

    def confirmed
      find_all_by_status(Recommendation::STATUS_CONFIRMED)
    end
  end

  # Users that have already been asked for a recommendation for this entry
  def recommendation_user_emails
    @recommendation_user_emails ||= self.recommendations.collect{|r| r.user.email}
  end

  def build_tags(tags)
    if tags && tags.length > 0
      parts = tags.split(",")
      parts.each do |t|
        tag = Tag.find_by_name(t)
        self.tags << tag if tag && !self.tags.include?(tag)
      end
    end
  end

  def update_tags(tags)
    if tags && tags.length > 0
      parts = tags.split(",")
      parts.each do |t|
        tag = Tag.find_by_name(t)
        self.tags << tag if tag && !self.tags.include?(tag)
      end
    end
  end

  def build_recommendations(emails, message, request)
    uuid = UUID.new
    if emails && emails.length > 0
      emails = emails.split(",")
      emails.each do |e|
        e.strip!
        next if self.recommendation_user_emails.include?(e)
        if e != "add emails for recommendations..."
          u = User.find_or_create_by_email(e)
          guid = uuid.generate
          if u.new_record?
            p u.randomize_password!
            u.first_name = "Guest"
            u.user_type = "recommender"
            u.save!
          end

          u.ensure_authentication_token!

          message = "<p>" + user.first_name + " says: \"" + message + "\"</p>" if message != ""

          #u.deliver_recommendation_request!(uuid, self.user.full_name)
          Mailer.recommendation_request({:uuid => guid,
                                         :recommendation_user => u,
                                         :request_user => self.user,
                                         :entry_title => self.title,
                                         :recommendation_message => message,
                                         :request => request }).deliver

          r = Recommendation.new(:user => u, :uuid => guid)
          self.recommendations << r
        end
      end
    end
  end

  def build_evidences(evidence)
    if evidence && evidence != ""
      self.evidence << EntryEvidence.new(:url => evidence)
    end
  end

  def update_evidences(evidence)
    if evidence && evidence != ""
      if self.evidence.any?
        e = EntryEvidence.find_by_id(self.evidence.first.id)
        e.url = evidence
        e.save!
      else
        self.evidence << EntryEvidence.new(:url => evidence)
      end
    else
      self.evidence=[]
    end
  end

  def self.process_suggestions(request_user, suggested_emails, title, request)
    found_user_count = 0
    if suggested_emails && suggested_emails.length > 0 && suggested_emails != "add emails for suggestions"
      emails = suggested_emails.split(",")
      emails.each do |e|
        u = User.first :conditions => ["email = ? and (user_type = ? or user_type = ?)", e, "regular", "admin"]
        if u
          found_user_count += 1
          Mailer.suggested_entry({:request_user => request_user,
                                  :suggested_user => u,
                                  :suggested_entry_title => title,
                                  :request => request}).deliver
        end
      end
    end

    found_user_count 
  end

  def self.find_by_tag_list(params = {})
    tags = params[:tags]
    include_recs = params[:include_recs]
    include_recs ||= false

    params[:start_date] = Date.strptime(params[:start_date], "%m/%d/%Y").strftime("%Y-%m-%d")
    params[:end_date] = Date.strptime(params[:end_date], "%m/%d/%Y").strftime("%Y-%m-%d")

    if !tags || tags.count == 0
      []
    else
      conditions = "entries_tags.tag_id IN(#{tags.join(",")}) AND entries.updated_at >= '#{params[:start_date]}' AND entries.updated_at <= '#{params[:end_date]}'"

      entries = self.all :select => "distinct entries.*", :conditions => conditions, :joins => [:entries_tags], :include => [:entries_tags, :user]

      if include_recs
        conditions = "recommendations_tags.tag_id IN(#{tags.join(",")}) AND recommendation.status = 'CONFIRMED' AND entries.updated_at >= '#{params[:start_date]}' AND entries.updated_at <= '#{params[:end_date]}'"
        recEntries = self.all :select => "distinct entries.*", :conditions => conditions, :joins => { :recommendations => :recommendations_tags }, :include => [{:recommendations => :recommendations_tags}, :user]

        recEntries.each{ |r|
          entries.push(r) unless entries.select{|e| e.id == r.id}.any?
        }
      end

      if params[:operator] == "and" && params[:type] == "selected"
        entries.reject!{ |entry| 
          tags_captured = []

          entry.entries_tags.each{|e|
            tags_captured.push(e.tag_id) if tags.include?(e.tag_id)
          }

          entry.recommendations_tags.each{|e|
            tags_captured.push(e.tag_id) if tags.include?(e.tag_id)
          }

          !((tags & tags_captured).length == tags.length)
        }
      end

      entries.sort!{|e1, e2| e1.user.last_name <=> e2.user.last_name} #order entries by user last name
    end
  end
end
