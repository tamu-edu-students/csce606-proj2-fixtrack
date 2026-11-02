class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_manager_role, only: [:create]

  private

  def set_manager_role
    params[:user] ||= {}
    params[:user][:role] = "manager"
  end
end