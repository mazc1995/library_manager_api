FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email }
    type { :member }
    password { "password123" }
    password_confirmation { "password123" }
  end
end 