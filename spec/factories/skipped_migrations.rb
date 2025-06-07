FactoryBot.define do
  factory :skipped_migration do
    version { "MyString" }
    filename { "MyString" }
    skipped_at { "2025-06-06 23:25:38" }
    reason { "MyString" }
  end
end
