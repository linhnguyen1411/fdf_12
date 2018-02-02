FactoryGirl.define do
  factory :domain do
    name {Faker::Lorem.word}
    created_at {Faker::Time.forward(27)}
    updated_at {Faker::Time.forward(28)}
  end
end
