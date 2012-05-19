class TagsController < ApplicationController
  def index
    by_user = params[:by_user]
    only_recent = params[:recent]
    only_recent ||= "0"

    if only_recent == "1"
      @tags = Tag.all_in_last_x_days()
    elsif by_user
      @tags = current_user.all_tags
    else
      @tags = Tag.all_with_counts()
    end

    respond_to do |format|
      format.json do
        render :json => @tags.collect{|t| {"id" => t[:tag].id, "text" => t[:tag].name, "value" => t[:count], "url" => "#"}}.to_json
      end
    end
  end
end
