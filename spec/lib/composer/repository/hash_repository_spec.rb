require_relative '../../../spec_helper'

describe Composer::Repository::HashRepository do

  HashRepository = Composer::Repository::HashRepository

  it '#add_package succeeds' do
    repo = HashRepository.new
    repo.add_package(self.get_package('foo', '1'))
    expect(repo.count).to be == 1
  end

  it '#remove_package succeeds' do
    package = self.get_package('bar', '2')
    repo = HashRepository.new
    repo.add_package(self.get_package('foo', '1'))
    repo.add_package(package)

    expect(repo.count).to be == 2
    repo.remove_package(self.get_package('foo', '1'))
    expect(repo.count).to be == 1
    expect(repo.packages).to be == [ package ]
  end

  it '#package? succeeds' do
    repo = HashRepository.new
    repo.add_package(self.get_package('foo', '1'))
    repo.add_package(self.get_package('bar', '2'))

    expect(repo.package?(self.get_package('foo', '1'))).to be true
    expect(repo.package?(self.get_package('bar', '1'))).to be false
  end

  it '#find_packages succeeds' do
    repo = HashRepository.new
    repo.add_package(self.get_package('foo', '1'))
    repo.add_package(self.get_package('bar', '2'))
    repo.add_package(self.get_package('bar', '3'))

    foo = repo.find_packages('foo')
    expect(foo.length).to be == 1
    expect(foo[0].name).to be == 'foo'

    bar = repo.find_packages('bar')
    expect(bar.length).to be == 2
    expect(bar[0].name).to be == 'bar'
  end

  it '#automatically adds aliased package' do
    repo = HashRepository.new
    package = self.get_package('foo', '1')
    alias_package = self.get_alias_package(package, '2')

    repo.add_package(alias_package)

    expect(repo.count).to be == 2

    expect(repo.package?(self.get_package('foo', '1'))).to be true
    expect(repo.package?(self.get_package('foo', '2'))).to be true
  end

end
