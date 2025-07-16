class ProfileController < ApplicationController
  before_action :set_user

  def show
  end

  private

  def set_user
    unless session[:user_id]
      redirect_to login_path and return
    end
    @user = User.find(session[:user_id])
  end
end