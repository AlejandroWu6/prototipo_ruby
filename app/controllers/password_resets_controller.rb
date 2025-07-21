class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email])
     if @user.present?
      PasswordMailer.with(user: @user).reset.deliver_now
    else
      render :new, status: :unprocessable_entity
    end
      redirect_to root_path, notice: "Password reset email sent."
  end
end
