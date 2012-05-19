class EntriesController < ApplicationController
  def index
    tags = params[:selected_tags].split(",").map{|tag| tag.to_i }
    type = "selected"
    if !tags.any?
      tags = params[:all_tags].split(",").map{|tag| tag.to_i }
      type = "all"
    end

    args = {
      :tags => tags,
      :type => type,
      :operator => params[:tag_operator],
      :start_date => params[:start_date],
      :end_date => params[:end_date]
    }

    @entries = Entry.find_by_tag_list(args)
    @tags = Tag.all

    render :partial => 'admin/skill_entry_list', :layout => false
  end

  def show
    @entry = Entry.find(params[:id])
  end

  def new
    render :partial => "home/new_entry_workspace"
  end

  def create
    request = { :host => self.request.host,
      :port => self.request.port,
      :protocol =>self.request.protocol}
    if params[:new_entry_suggestions]
      found_user_count = Entry.process_suggestions(current_user, params[:new_entry_suggestions], params[:title], request)
      render :text => found_user_count, :layout => false
    else
      @entry = current_user.entries.build(params[:entry])
      @entry.build_tags(params[:new_entry_tags])
      @entry.build_recommendations(params[:recommendation_emails], params[:recommendation_message], request)
      @entry.build_evidences(params[:new_entry_evidence])
      if @entry.save
        respond_to do |format|
          format.html {
            render :partial => "entry", :object => @entry, :layout => false
          }
          format.json {
            render :json => {:message => "success"}.to_json
          }
        end
      end
    end
  end

  def edit
    @entry = Entry.find_by_id(params[:id])
    render :partial => "entries/edit_entry", :layout => false
  end

  def update
    request = { :host => self.request.host,
      :port => self.request.port,
      :protocol =>self.request.protocol}

    @entry = Entry.find_by_id(params[:id])
    @entry.title = params[:entry][:title]
    @entry.reflection = params[:entry][:reflection]
    @entry.update_tags(params[:entry_tags])
    @entry.update_evidences(params[:entry_evidence])
    @entry.build_recommendations(params[:recommendation_emails], params[:recommendation_message], request)
    if @entry.save
      render :partial => "entries/entry", :object => @entry, :layout => false
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    if @entry
      @entry.destroy
    end

    render :text => "entry deleted", :status => :ok, :layout => false
  end
end

