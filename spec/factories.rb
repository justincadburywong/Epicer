FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password "helloworld"
    password_confirmation "helloworld"
    remember_created_at Time.now
  end

  factory :recipe do
    name { Faker::Name.name }
    description { Faker::Hipster.sentence }
    source { Faker::Internet.url }
    category { Faker::Hipster.words(3) }
    prep_time { Faker::Number.between(10, 120) }
    servings { Faker::Number.between(1, 8) }
    cals_serving { Faker::Number.number(3) }
    attachments { Faker::File.file_name('foo/bar', 'fake', 'jpg')}
    notes { Faker::Hipster.sentence(3) }
    ingredient1 { Faker::Food.ingredient }
    ingredient2 { Faker::Food.ingredient }
    ingredient3 { Faker::Food.ingredient }
    ingredient4 { Faker::Food.ingredient }
    ingredient5 { Faker::Food.ingredient }
    ingredient6 { Faker::Food.ingredient }
    ingredient7 { Faker::Food.ingredient }
    ingredient8 { Faker::Food.ingredient }
    ingredient9 { Faker::Food.ingredient }
    ingredient10 { Faker::Food.ingredient }
    ingredient11 { Faker::Food.ingredient }
    ingredient12 { Faker::Food.ingredient }
    ingredient13 { Faker::Food.ingredient }
    ingredient14 { Faker::Food.ingredient }
    ingredient15 { Faker::Food.ingredient }
    ingredient16 { Faker::Food.ingredient }
    ingredient17 { Faker::Food.ingredient }
    ingredient18 { Faker::Food.ingredient }
    ingredient19 { Faker::Food.ingredient }
    ingredient20 { Faker::Food.ingredient }
    ingredient21 { Faker::Food.ingredient }
    ingredient22 { Faker::Food.ingredient }
    quantity1 { Faker::Food.measurement }
    quantity2 { Faker::Food.measurement }
    quantity3 { Faker::Food.measurement }
    quantity4 { Faker::Food.measurement }
    quantity5 { Faker::Food.measurement }
    quantity6 { Faker::Food.measurement }
    quantity7 { Faker::Food.measurement }
    quantity8 { Faker::Food.measurement }
    quantity9 { Faker::Food.measurement }
    quantity10 { Faker::Food.measurement }
    quantity11 { Faker::Food.measurement }
    quantity12 { Faker::Food.measurement }
    quantity13 { Faker::Food.measurement }
    quantity14 { Faker::Food.measurement }
    quantity15 { Faker::Food.measurement }
    quantity16 { Faker::Food.measurement }
    quantity17 { Faker::Food.measurement }
    quantity18 { Faker::Food.measurement }
    quantity19 { Faker::Food.measurement }
    quantity20 { Faker::Food.measurement }
    quantity21 { Faker::Food.measurement }
    quantity22 { Faker::Food.measurement }
    instruction1 {Faker::Hipster.sentence }
    instruction2 {Faker::Hipster.sentence }
    instruction3 {Faker::Hipster.sentence }
    instruction4 {Faker::Hipster.sentence }
    instruction5 {Faker::Hipster.sentence }
    instruction6 {Faker::Hipster.sentence }
    instruction7 {Faker::Hipster.sentence }
    instruction8 {Faker::Hipster.sentence }
    instruction9 {Faker::Hipster.sentence }
    instruction10 {Faker::Hipster.sentence }
    instruction11 {Faker::Hipster.sentence }
    instruction12 {Faker::Hipster.sentence }
    instruction13 {Faker::Hipster.sentence }
    instruction14 {Faker::Hipster.sentence }
    instruction15 {Faker::Hipster.sentence }
    instruction16 {Faker::Hipster.sentence }
    instruction17 {Faker::Hipster.sentence }
    instruction18 {Faker::Hipster.sentence }
    instruction19 {Faker::Hipster.sentence }
    instruction20 {Faker::Hipster.sentence }
  end
end
