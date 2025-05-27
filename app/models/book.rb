class Book < ApplicationRecord
  has_many :borrows, dependent: :destroy

  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :copies, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :available, inclusion: { in: [true, false] }

  before_save :update_available

  def update_available
    self.available = self.copies > 0 ? true : false
  end
end
