class MaintenanceTicketPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def update_priority?
    %w[manager admin].include?(@user&.role) && @record.status != "closed"
  end
end
