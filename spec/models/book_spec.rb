require 'rails_helper'

RSpec.describe Book, type: :model do
  subject { build(:book) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:genre) }
    it { should validate_presence_of(:isbn) }
    it { should validate_uniqueness_of(:isbn) }
    it { should validate_numericality_of(:copies).is_greater_than_or_equal_to(0) }
  end
end
