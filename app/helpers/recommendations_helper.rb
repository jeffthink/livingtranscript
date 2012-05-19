module RecommendationsHelper
  def recommendation_default(r)
    if r.text && r.text != ""
      r.text
    else
      "recommendation..."
    end
  end

  def recommendation_default?(r)
    r.text == nil || r.text == ""
  end

  def feedback_default(r)
    if r.feedback && r.feedback != ""
      r.feedback
    else
      "constructive feedback..."
    end
  end

  def feedback_default?(r)
    r.feedback == nil || r.feedback == ""
  end

  def relationship_default(r)
    if r.relationship && r.relationship != ""
      r.relationship
    else
      "specify your relationship..."
    end
  end

  def relationship_default?(r)
    r.relationship == nil || r.relationship == ""
  end
end
