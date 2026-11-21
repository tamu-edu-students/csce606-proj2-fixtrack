class PreventiveMaintenanceSchedulePolicy
  def initialize(user, _record)
    @user = user
  end

  def index?
    !@user.nil?
  end

  def create?
    @user&.manager? || false
  end

  alias_method :new?, :create?
end
