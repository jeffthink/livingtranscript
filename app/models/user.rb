class User < ActiveRecord::Base
  self.per_page = 10
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :authentication_token

  has_many :entries do
    def sorted_by_most_recent
      all(:order => "entries.updated_at DESC")
    end
  end

  has_many :recommendations, :through => :entries do
    def pending
      find_all_by_status(Recommendation::STATUS_PENDING_APPROVAL)
    end

    def confirmed
      find_all_by_status(Recommendation::STATUS_CONFIRMED)
    end

    def confirmed_count
      count(:conditions => {:status => Recommendation::STATUS_CONFIRMED})
    end
  end

  has_many :requested_recommendations, :class_name => "Recommendation" do
    def new
      find_all_by_status(Recommendation::STATUS_NEW)
    end

    def pending
      find_all_by_status(Recommendation::STATUS_PENDING_APPROVAL)
    end

    def confirmed
      find_all_by_status(Recommendation::STATUS_CONFIRMED)
    end

    def denied
      find_all_by_status(Recommendation::STATUS_DENIED)
    end
  end

  def all_tags
    Tag.all_by_user({:userId => self.id})
  end

  def entry_tags
    Tag.all_by_user({:userId => self.id, :type => "me"})
  end

  def recommendation_tags
    Tag.all_by_user({:userId => self.id, :type => "recommendation"})
  end

  def tags
    all_tags.sort_by {|tag| tag[:count]}
  end

  def tag_count
    sum = 0
    tags.each{|tag| sum += tag[:count] }
    sum
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def randomize_password!
    p = SecureRandom.base64(6)
    self.password = p
    self.password_confirmation = p
    p
  end

  def ensure_authentication_token!
    reset_authentication_token! if authentication_token.blank?
  end

  def is_recommender?
    self.user_type == 'recommender'
  end

  def is_admin?
    self.user_type == "admin"
  end

  def is_regular?
    self.user_type == "regular"
  end
end
