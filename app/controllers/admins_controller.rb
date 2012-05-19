class AdminsController < ApplicationController
  before_filter :authenticate_user!

  def index
    if current_user
      if current_user.is_admin?
        render "admin/index"
      end
    end
  end
end
