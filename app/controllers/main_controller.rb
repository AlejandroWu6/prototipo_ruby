class MainController < ApplicationController
  def index
    flash[:notice]
    flash[:alert]
  end
end