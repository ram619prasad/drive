FactoryBot.define do
  factory :folder do
    user
    name { Faker::Lorem.characters(number: 10) }

    trait :with_files do
      after :create do |folder|
        img = Rack::Test::UploadedFile.new(Rails.root.join('test', 'assets', 'sample.jpg'), 'image/jpeg')
        folder.files.attach(img)
        pdf = Rack::Test::UploadedFile.new(Rails.root.join('test', 'assets', 'sample.pdf'), 'application/pdf')
        folder.files.attach(pdf)
      end
    end
  end
end
  