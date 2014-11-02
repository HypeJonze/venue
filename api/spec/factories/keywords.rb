FactoryGirl.define do
  factory :keyword do
    name Faker::Lorem.word
    category { create(:category) }
  end
end