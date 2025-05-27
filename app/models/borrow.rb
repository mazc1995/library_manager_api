class Borrow < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :user_id, presence: true
  validates :book_id, presence: true
  validates :borrow_date, presence: true
  validates :due_date, presence: true
  validate :due_date_after_borrow_date
  validate :returned_date_after_borrow_date

  private

  def due_date_after_borrow_date
    if due_date.present? && borrow_date.present? && due_date < borrow_date
      errors.add(:due_date, "must be after borrow date")
    end
  end

  def returned_date_after_borrow_date
    if returned_date.present? && borrow_date.present? && returned_date < borrow_date
      errors.add(:returned_date, "must be after borrow date")
    end
  end
end
