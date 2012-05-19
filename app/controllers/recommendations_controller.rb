class RecommendationsController < ApplicationController
  before_filter :authenticate_user!

  # Our "new" method is different than most RESTful resources
  # The actual recommendation object has already been created,
  # but we want it to look to the user like they are creating a new one
  def new
    @recommendation ||= Recommendation.find_by_uuid(params[:id])
    if !@recommendation
      flash[:message] = "We're sorry, that request has been removed by the requester"
      redirect_to :root
    elsif @recommendation.status != Recommendation::STATUS_NEW
      flash[:message] = "Thanks for your recommendation!"
      redirect_to :root
    end
  end

  def show
    @recommendation = Recommendation.find_by_id(params[:id], :include => [:evidence])
    @recommendation ||= Recommendation.find_by_uuid(params[:id], :include => [:evidence])
    redirect_to :controller => "home", :action => "index" if !@recommendation
  end

  def update
    request = { :host => self.request.host,
      :port => self.request.port,
      :protocol =>self.request.protocol}

    @recommendation = Recommendation.find_by_id(params[:id])
    @recommendation ||= Recommendation.find_by_uuid(params[:id])

    if params[:status_only]
      @recommendation.status = params[:recommendation][:status]
    else
      @recommendation.text = params[:recommendation][:text]
      @recommendation.feedback = params[:recommendation][:feedback]
      @recommendation.relationship = params[:recommendation][:relationship]
      @recommendation.status = params[:recommendation][:status]
      @recommendation.build_tags(params[:recommendation_tags])
      @recommendation.build_evidences(params[:recommendation_evidence])
      @recommendation.notify_entry_user!(request)
    end

    if @recommendation.save
      respond_to do |format|
        format.json do
          render :json => {:message => "Ok"}.to_json
        end
      end
    else
      respond_to do |format|
        format.json do
          render :json => {:error => @recommendation.errors}.to_json, :status => :internal_server_error
        end
      end
    end
  end
end
