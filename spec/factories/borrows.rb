FactoryBot.define do
  factory :borrow do
    borrow_date { Date.current }
    due_date { Date.current + 14.days }
    user { create(:user) }
    book { create(:book) }
    returned { false }
    returned_date { nil }
  end
end
