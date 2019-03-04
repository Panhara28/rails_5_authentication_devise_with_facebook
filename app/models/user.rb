class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  has_many :services, dependent: :destroy
end
