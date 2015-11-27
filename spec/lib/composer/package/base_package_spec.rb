require_relative '../../../spec_helper'

describe BasePackage do

  it 'should set same repository' do
    package = BasePackage.new('foo')
    repository = HashRepository.new()
    package.repository = repository

    begin
      package.repository = repository
    rescue
      fail('Set against the same repository is allowed.');
    end

  end

  it 'should not set other repository' do
    package = BasePackage.new('foo')
    repository = HashRepository.new()
    package.repository = repository

    expect { package.repository = HashRepository.new() }.to raise_error(Composer::LogicError)
  end

end


