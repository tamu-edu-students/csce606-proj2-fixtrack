#code for handling manager provision of users
class UsersController < ApplicationController
    #decise auth methods
    before_action :authenticate_user!
    before_action :require_manager!

def new
    @user = User.new
end

def create
  @user = current_user.company.users.build(user_params)

  if @user.save
    @success_message = "#{@user.role.capitalize} created successfully."
    @user = User.new
  else
    @success_message = nil
  end

  render :new
end

def require_manager!
    unless current_user.role == "manager"
      redirect_to root_path, alert: "You are not authorized to create users."
    end
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :role
    ).tap do |attributes|
      attributes[:role] = nil unless %w[technician reporter].include?(attributes[:role])
    end
  end
end
