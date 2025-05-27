require 'rails_helper'

RSpec.describe BorrowRepository, type: :repository do
  let!(:borrow) { create(:borrow) }

  describe '#list_borrows' do
    it 'returns all borrows' do
      expect(BorrowRepository.new.list_borrows({})).to include(borrow)
    end
  end

  describe '#show_borrow' do
    it 'returns a borrow' do
      expect(BorrowRepository.new.show_borrow(id: borrow.id)).to eq(borrow)
    end
  end

  describe '#create_borrow' do
    it 'creates a borrow' do
      user = create(:user)
      book = create(:book)
      params = { user_id: user.id, book_id: book.id, borrow_date: Date.today, due_date: Date.today + 1.week }
      expect { BorrowRepository.new.create_borrow(params) }.to change(Borrow, :count).by(1)
    end
  end

  describe '#destroy_borrow' do
    it 'destroys a borrow' do
      expect { BorrowRepository.new.destroy_borrow(borrow.id) }.to change(Borrow, :count).by(-1)
    end
  end
end