FactoryGirl.define do
  factory :neighbourhood do
    name { Faker::Address.secondary_address }
  end
end