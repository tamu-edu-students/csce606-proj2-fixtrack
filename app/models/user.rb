class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: true
  validates :role, inclusion: { in: %w[manager technician reporter] }
  belongs_to :company, optional: true

  before_validation :assign_default_role, on: :create

  def manager?
    role == "manager"
  end

  def technician?
    role == "technician"
  end

  def reporter?
    role == "reporter"
  end

  private

  def assign_default_role
    self.role ||= "reporter"
  end
end
