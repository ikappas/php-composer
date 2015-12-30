require_relative '../spec_helper'

FactoryGirl.define do

  factory :alias_package, class: ::Composer::Package::AliasPackage do
    transient do
      alias_of :package
      version '1.0'
    end
    initialize_with do
      parser = ::Composer::Semver::VersionParser.new
      new( alias_of, parser.normalize(version), version)
    end
  end

  factory :root_package, class: ::Composer::Package::RootPackage do
    transient do
      name 'foo'
      version '1.0'
    end
    initialize_with do
      parser = ::Composer::Semver::VersionParser.new
      new( name, parser.normalize(version), version)
    end
  end

  factory :complete_package, class: ::Composer::Package::CompletePackage do
    transient do
      name 'foo'
      version '1.0'
    end
    initialize_with do
      parser = ::Composer::Semver::VersionParser.new
      new( name, parser.normalize(version), version)
    end
  end

  factory :package, class: ::Composer::Package::Package do
    transient do
      name 'foo'
      version '1.0'
    end
    initialize_with do
      parser = ::Composer::Semver::VersionParser.new
      new( name, parser.normalize(version), version)
    end
  end

  factory :link, class: ::Composer::Package::Link do

    trait :foo do
      initialize_with do
        constraint = ::Composer::Semver::Constraint::Constraint.new('=', '1.0.0.0')
        new('foo', 'foo/bar', constraint, 'requires', '1.0.0')
      end
    end

    trait :bar do
      initialize_with do
        constraint = ::Composer::Semver::Constraint::Constraint.new('=', '1.0.0.0')
        new('bar', 'bar/baz', constraint, 'requires', '1.0.0')
      end
    end

  end

end
