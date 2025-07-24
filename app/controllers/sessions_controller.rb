class SessionsController < ApplicationController
  def new
    @user = User.new
    if session[:user_id]
      redirect_to root_path, notice: "You are already logged in."
    end
  end

  def create
    email = params.dig(:user, :email)
    password = params.dig(:user, :password)
    user = User.find_by(email: email)
    if user&.authenticate(password)
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully."
    else
      @user = User.new(email: email)
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Rails.logger.debug "EntranaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaAAAAAAAAAAAAAAAAAAAAdoEntranaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaAAAAAAAAAAAAAAAAAAAAdoEntranaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaAAAAAAAAAAAAAAAAAAAAdoEntranaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaAAAAAAAAAAAAAAAAAAAAdoEntranaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaAAAAAAAAAAAAAAAAAAAAdoEntranaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaAAAAAAAAAAAAAAAAAAAAdo a SessionsController#destroy"

    session[:user_id] = nil
    reset_session
    redirect_to root_path, notice: "Logged out successfully."
  end
end