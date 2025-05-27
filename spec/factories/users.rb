FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email }
    role { :member }
    password { "password123" }
    password_confirmation { "password123" }
  end
end 