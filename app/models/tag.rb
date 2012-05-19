class Tag < ActiveRecord::Base
  has_and_belongs_to_many :entries
  has_and_belongs_to_many :recommendations

  def self.count_all
    sum = 0
    find_with_counts.each{|tag| sum += tag[:count] }
    sum
  end

  def self.all_with_counts
    find_with_counts
  end

  def self.all_by_user(params={})
    where = nil
    if(params[:userId])
      where = "entries.user_id = #{params[:userId]}"
    end
    
    test = find_with_counts(where, where, true)
    test
  end

  def self.all_in_last_x_days(params={})
    params[:days] ||=  7
    whereMe = "entries_tags.updated_at > " + params[:days].days.ago.strftime("%Y-%m-%d");
    whereYou = "recommendations_tags.updated_at > " + params[:days].days.ago.strftime("%Y-%m-%d");

    find_with_counts(whereMe, whereYou, true)
  end

  def self.find_with_counts(entryWhere = nil, recWhere = nil, onlyTagsWithCounts = false)
    ret = self.find_in_entry_with_count(entryWhere)
    rrt = self.find_in_recommendation_with_count(recWhere)
    in_entry_or_rec = self.merge_tags_with_counts(ret, rrt)

    all = self.all.map{|tag| {:tag => tag, :count => (in_entry_or_rec.include?(tag.id) ? in_entry_or_rec[tag.id] : 0)}}

    if onlyTagsWithCounts
      all = all.reject{|tag| tag[:count] == 0}
    end

    all.shuffle
  end

  def self.merge_tags_with_counts(*args)
    all = {}
    
    if(args.length >= 1)
      args[0].map{|t| all[t.id] = t.tag_count}

      if(args.length > 1)
        args[1,args.length - 1].each do |tags|
          tags.each do |t|
            all[t.id] += t.tag_count if all.include?(t.id)
            all[t.id] = t.tag_count if !all.include?(t.id)
          end
        end
      end
    end

    all
  end

  def self.find_in_entry_with_count(where = nil)
    conditions = []
    if(where)
      conditions.push(where)
    end
    self.all :select => "count(entries_tags.entry_id) AS tag_count, tags.id", :joins => [:entries], :group => "tags.id", :conditions => conditions
  end

  def self.find_in_recommendation_with_count(where = nil)
    conditions = []
    if(where)
      conditions.push(where)
    end
    conditions.push("recommendations.status='CONFIRMED'")
    self.all :select => "count(recommendations_tags.recommendation_id) AS tag_count, tags.id", :joins => {:recommendations => [:entry]}, :group => "tags.id", :conditions => conditions
  end
end
