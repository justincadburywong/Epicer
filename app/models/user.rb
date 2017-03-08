class User < ApplicationRecord
  has_secure_password
  has_many :recipes, dependent: :destroy

  validates :first_name, :last_name, :email, :password, presence: true
  validates :password, length: { minimum: 6 }
  validates_associated :recipes
  validates :email, uniqueness: true
            format { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
            message: "Incorrect email format"}
end
