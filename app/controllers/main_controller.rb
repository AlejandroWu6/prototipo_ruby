class MainController < ApplicationController
  def index
    if session[:user_id]
      @user = User.find_by(id: session[:user_id])
      unless @user
        reset_session  
        redirect_to login_path, alert: "Session expired. Please log in again."
      end
          @invoices = current_user.invoices
    end
  end
end
