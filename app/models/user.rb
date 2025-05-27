class User < ApplicationRecord
  has_secure_password

  has_many :borrows, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :type, presence: true
  validates :password_digest, presence: true, length: { minimum: 8 }
  

  enum :type, [:member, :librarian]
end
