class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :recipes, dependent: :destroy

  validates :email, :password, presence: true
  validates :password, length: { minimum: 6 }
  validates_associated :recipes
  validates :email, uniqueness: true,
           format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
           message: "Incorrect email format" }
end
