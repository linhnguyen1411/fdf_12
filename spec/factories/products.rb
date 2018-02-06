FactoryGirl.define do
  factory :product do
    description {Faker::Hacker.say_something_smart}
    price {Faker::Number.decimal(1)}
    status 0
    name {Faker::Name.name}
    image {Faker::Name.name}
    category nil
    shop nil
    user nil
    start_hour "07:00:00"
    end_hour "20:00:00"
  end
end
