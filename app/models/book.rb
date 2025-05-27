class Book < ApplicationRecord
  has_many :borrows, dependent: :destroy

  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :copies, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :available, inclusion: { in: [true, false] }

end
