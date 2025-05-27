FactoryBot.define do
  factory :book do
    title { "MyString" }
    author { "MyString" }
    genre { "MyString" }
    isbn { Random.hex(10) }
    copies { 1 }
    available { true }
  end
end
