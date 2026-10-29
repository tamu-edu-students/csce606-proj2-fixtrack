class Company < ApplicationRecord
    has_many :users, dependant: :restrict_with_error
    validates :name, presence: true
end
