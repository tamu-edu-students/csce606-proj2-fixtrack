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
        redirect_to root_path, notice: "#{@user.role.capitalize} created successfully."
    else
        render :new, status: :unprocessable_entity
    end
end