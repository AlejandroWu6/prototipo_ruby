class RegistrationsController < ApplicationController
  def new
    @user = User.new
     if session[:user_id]
      redirect_to root_path, notice: "You are already logged in."
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end