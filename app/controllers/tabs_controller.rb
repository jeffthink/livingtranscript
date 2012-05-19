class TabsController < ApplicationController
  def index
    render_tab(params[:tab], params)
  end

  private

  def render_tab(tab, params={})
    if params[:id]
      @entry = Entry.find_by_id(params[:id]) if tab == "entries"
      @recommendation = Recommendation.find_by_id(params[:id]) if tab == "recommendations"
    end

    render :partial => "entries/entries_tab", :layout => false if tab == "entries"
    render :partial => "recommendations/recommendations_tab", :layout => false if tab == "recommendations"
    render :partial => "tags/tags_tab", :layout => false if tab == "tags"
  end
end
