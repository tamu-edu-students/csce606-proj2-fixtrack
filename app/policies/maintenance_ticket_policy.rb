class MaintenanceTicketPolicy
  def initialize(user, _record)
    @user = user
  end

  def update_priority?
    %w[manager admin].include?(@user&.role)
  end
end
