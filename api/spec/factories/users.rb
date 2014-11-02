# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email 'johndoe@example.com'
    password 'password'
    password_confirmation 'password'
    family_name 'Doe'
    given_name 'John'
    picture 'https://lh5.googleusercontent.com/-Q2Wz058FlOk/AAAAAAAAAAI/AAAAAAAAB-A/_XgI3TBcv-s/photo.jpg'
  end

  factory :admin, :class => User do
    email 'admin@example.com'
    password 'password'
    password_confirmation 'password'
    role 'admin'
  end
end
