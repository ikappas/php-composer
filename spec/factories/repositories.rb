require_relative '../spec_helper'

FactoryGirl.define do

  factory :hash_repository, class: ::Composer::Repository::HashRepository do
    transient do
      packages []
    end
    initialize_with { new(packages) }

    trait :empty do
      initialize_with do
        new([])
      end
    end

  end

end
