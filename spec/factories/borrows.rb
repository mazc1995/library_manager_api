FactoryBot.define do
  factory :borrow do
    borrow_date { Time.now }
    due_date { Time.now + 2.weeks }
    user { create(:user) }
    book { create(:book) }
  end
end
