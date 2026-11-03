class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validates :role, inclusion: { in: %w[manager technician reporter] }

  belongs_to :company, optional: true

  attr_accessor :company_name

  before_validation :build_company, on: :create
  before_validation :set_manager_role, on: :create

  validates :company_name, presence: true, on: :create

  private

  def build_company
    if company_name.present? && company.nil?
      self.company = Company.new(name: company_name)
    end
  end

  def set_manager_role
    self.role = "manager" if role.blank?
  end
end