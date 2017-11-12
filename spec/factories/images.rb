FactoryBot.define do

  factory :image do
    sequence(:caption) {|n| n%2==0 ? nil : Faker::Lorem.sentence(3).chomp(".") }
    creator_id 1
    image_content { FactoryBot.attributes_for(:image_content) }
    position      { FactoryBot.build(:point).to_hash }

    after(:build) do |image|
      image.image_content = FactoryBot.build(:image_content, image.image_content) if image.image_content
    end
    transient do
      sizes 5
    end
    after(:create) do |image, props|
      if props.sizes==1
        image.image_content.image_id=image.id
        image.image_content.save!
      elsif props.sizes > 1
        ImageContentCreator.new(image).build_contents.save! if image.image_content
      end
    end

    trait :with_caption do
      caption { Faker::Lorem.sentence(1).chomp(".") }
    end

    trait :with_roles do
      after(:create) do |image|
        Role.create(:role_name=>Role::ORGANIZER,
                    :mname=>Image.name,
                    :mid=>image.id,
                    :user_id=>image.creator_id)
      end
    end
  end

end
