class PasswordResetsController < ApplicationController
  def new
  end

 def edit
    @user = User.find_signed!(params[:token], purpose: "password_reset")
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to login_path, alert: "Invalid or expired password reset token. Please try again."
  end

 def update
      @user = User.find_signed!(params[:token], purpose: "password_reset")
      if @user.update(password_params)
        redirect_to login_path, notice: "Password has been reset successfully. You can now log in."
      else
        flash.now[:alert] = "Failed to reset password. Please check your inputs."
        render :edit, status: :unprocessable_entity
      end
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

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
