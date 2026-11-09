class EquipmentPolicy
  def initialize(user, _record)
    @user = user
  end

  def index?
    !@user.nil?
  end

  alias_method :show?, :index?

  def create?
    manager?
  end

  alias_method :new?, :create?
  alias_method :edit?, :create?
  alias_method :update?, :create?
  alias_method :destroy?, :create?
  alias_method :confirm_destroy?, :create?

  private

  def manager?
    @user&.manager?
  end
end
