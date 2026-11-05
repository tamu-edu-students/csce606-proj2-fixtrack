#code for handling manager provision of users
class UsersController < ApplicationController
    #decise auth methods
    before_action :authenticate_user!
    before_action :require_manager!

def new
    @user = User.new
end

#handles managers creation of new users, and addigns managers
#company aytomatically
def create
    @user = current_user.company.users.build(user_params)
    if @user.save
        redirect_to root_path, notice: "#{@user.role.capitalize} created successfully."
    else
        render :new, status: :unprocessable_entity
    end
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
