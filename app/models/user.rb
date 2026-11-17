
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validates :role, inclusion: { in: %w[manager technician reporter] }

  belongs_to :company

  has_many :repair_records,
           foreign_key: :technician_id,
           class_name: "RepairRecord"

  attr_accessor :company_name

  before_validation :build_company, on: :create
  before_validation :assign_role, on: :create

  validates :company_name, presence: true,
            on: :create,
            if: -> { company.nil? }

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

  def build_company
    if company_name.present? && company.nil?
      self.company = Company.new(name: company_name)
    end
  end

  def assign_role
    if company_name.present?
      self.role = "manager"
    else
      self.role ||= "reporter"
    end
  end
end
