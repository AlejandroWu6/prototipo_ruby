class ProfileController < ApplicationController
  before_action :set_user

  def show
  end

  def destroy
    if @user.nil?
      redirect_to root_path, alert: "Usuario no encontrado." and return
    end
    @user.destroy if @user
    reset_session
    redirect_to root_path, notice: "Tu usuario ha sido eliminado correctamente."
  end

  private

  def set_user
    unless session[:user_id]
      redirect_to login_path and return
    end
    @user = Current.user
  end
end