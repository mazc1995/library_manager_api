class User < ApplicationRecord
  has_secure_password
  before_create :generate_auth_token

  has_many :borrows, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :password_digest, presence: true, length: { minimum: 8 }
  

  enum :role, [:member, :librarian]

  private

  def generate_auth_token
    self.auth_token = SecureRandom.hex(16)
  end
end
