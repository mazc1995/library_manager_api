require 'rails_helper'

RSpec.describe Borrow, type: :model do
  let(:borrow) { create(:borrow) }

  it 'has a valid factory' do
    expect(borrow).to be_valid
  end

  it 'is invalid without a user' do
    borrow.user = nil
    expect(borrow).to be_invalid
  end

  it 'is invalid without a book' do
    borrow.book = nil
    expect(borrow).to be_invalid
  end

  it 'is invalid with a due date before the borrow date' do
    borrow.due_date = borrow.borrow_date - 1.day
    expect(borrow).to be_invalid
  end

  it 'is valid with a due date after the borrow date' do
    borrow.due_date = borrow.borrow_date + 1.day
    expect(borrow).to be_valid
  end
end
