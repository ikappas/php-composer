require_relative '../../../spec_helper'

describe Composer::Package::BasePackage do

  it 'should set same repository' do
    package = Composer::Package::BasePackage.new('foo')
    repository = Composer::Repository::HashRepository.new()
    package.repository = repository

    begin
      package.repository = repository
    rescue
      fail('Set against the same repository is allowed.');
    end

  end

  it 'should not set other repository' do
    package = Composer::Package::BasePackage.new('foo')
    repository = Composer::Repository::HashRepository.new()
    package.repository = repository

    expect { package.repository = Composer::Repository::HashRepository.new() }.to raise_error(Composer::LogicError)
  end

end


