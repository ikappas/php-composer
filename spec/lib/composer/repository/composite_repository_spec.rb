require_relative '../../../spec_helper'

describe Composer::Repository::CompositeRepository do

  CompositeRepository = Composer::Repository::CompositeRepository

  context 'with packages' do

    it '#package? succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1'))

      repo = CompositeRepository.new([ hash_repo_1, hash_repo_2 ])

      # Should have package 'foo/1'
      expect(repo.package?(self.get_package('foo', '1'))).to be true

      # Should have package 'bar/1'
      expect(repo.package?(self.get_package('bar', '1'))).to be true

      # Should not have package 'foo/2'
      expect(repo.package?(self.get_package('foo', '2'))).to be false

      # Should not have package 'bar/2'
      expect(repo.package?(self.get_package('bar', '2'))).to be false
    end

    it '#find_package succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1'))

      repo = CompositeRepository.new([ hash_repo_1, hash_repo_2 ])

      # Should find package 'foo/1' and get name of 'foo'
      expect(repo.find_package('foo', '1').name).to be == 'foo'

      # Should find package 'foo/1' and get pretty version of '1'
      expect(repo.find_package('foo', '1').pretty_version).to be == '1'

      # Should find package 'bar/1' and get name of 'bar'
      expect(repo.find_package('bar', '1').name).to be == 'bar'

      # Should find package 'bar/1' and get pretty version of '1'
      expect(repo.find_package('bar', '1').pretty_version).to be == '1'

      # Should not find package 'foo/2'
      expect(repo.find_package('foo', '2')).to be_nil
    end

    it '#find_packages succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1'))
      hash_repo_1.add_package(self.get_package('foo', '2'))
      hash_repo_1.add_package(self.get_package('bat', '1'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1'))
      hash_repo_2.add_package(self.get_package('bar', '2'))
      hash_repo_2.add_package(self.get_package('foo', '3'))

      repo = CompositeRepository.new([ hash_repo_1, hash_repo_2 ])

      bat_packages = repo.find_packages('bat')

      # Should find one instance of 'bat_packages' (defined in just one repository)
      expect(bat_packages.length).to be == 1

      # "Should find packages named 'bat'"
      expect(bat_packages[0].name).to be == 'bat'

      bar_packages = repo.find_packages('bar')

      # Should find two instances of 'bar' (both defined in the same repository)
      expect(bar_packages.length).to be == 2

      # Should find packages named 'bar'
      expect(bar_packages[0].name).to be == 'bar'
      expect(bar_packages[0].pretty_version).to be == '1'
      expect(bar_packages[1].name).to be == 'bar'
      expect(bar_packages[1].pretty_version).to be == '2'

      foo_packages = repo.find_packages('foo')

      # Should find three instances of 'foo' (two defined in one repository, the third in the other)
      expect(foo_packages.length).to be == 3

      # Should find packages named 'foo'
      expect(foo_packages[0].name).to be == 'foo'
      expect(foo_packages[0].pretty_version).to be == '1'
      expect(foo_packages[1].name).to be == 'foo'
      expect(foo_packages[1].pretty_version).to be == '2'
      expect(foo_packages[2].name).to be == 'foo'
      expect(foo_packages[2].pretty_version).to be == '3'
    end

    it '#search with search name mode  succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1', 'Composer::Package::CompletePackage'))
      hash_repo_1.add_package(self.get_package('foo', '2', 'Composer::Package::CompletePackage'))
      hash_repo_1.add_package(self.get_package('bat', '1', 'Composer::Package::CompletePackage'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1', 'Composer::Package::CompletePackage'))
      hash_repo_2.add_package(self.get_package('bar', '2', 'Composer::Package::CompletePackage'))
      hash_repo_2.add_package(self.get_package('foo', '3', 'Composer::Package::CompletePackage'))

      repo = CompositeRepository.new([ hash_repo_1, hash_repo_2 ])

      bat_packages = repo.search('bat', Composer::Repository::BaseRepository::SEARCH_NAME)

      # Should find one instance of 'bat_packages' (defined in just one repository)
      expect(bat_packages.length).to be == 1

      # Should find packages named 'bat'"
      expect(bat_packages[0]['name']).to be == 'bat'

      bar_packages = repo.search('bar', Composer::Repository::BaseRepository::SEARCH_NAME)

      # Should find two instances of 'bar' (defined in just one repository)
      expect(bar_packages.length).to be == 1

      # Should find packages named 'bar'
      expect(bar_packages[0]['name']).to be == 'bar'

      foo_packages = repo.search('foo', Composer::Repository::BaseRepository::SEARCH_NAME)

      # Should find 'bar'
      expect(foo_packages.length).to be == 2

      # Should find packages named 'bar'
      expect(foo_packages[0]['name']).to be == 'foo'
      expect(foo_packages[1]['name']).to be == 'foo'

    end

    it '#search with search full text mode  succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1', 'Composer::Package::CompletePackage'))
      hash_repo_1.add_package(self.get_package('foo', '2', 'Composer::Package::CompletePackage'))
      hash_repo_1.add_package(self.get_package('bat', '1', 'Composer::Package::CompletePackage'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1', 'Composer::Package::CompletePackage'))
      hash_repo_2.add_package(self.get_package('bar', '2', 'Composer::Package::CompletePackage'))
      package_2 = self.get_package('foo', '3', 'Composer::Package::CompletePackage')
      allow(package_2).to receive(:description).and_return( 'sample desc' )
      allow(package_2).to receive(:keywords).and_return(%w{platform forms})
      hash_repo_2.add_package(package_2)


      repo = CompositeRepository.new([ hash_repo_1, hash_repo_2 ])

      bat_packages = repo.search('bat', Composer::Repository::BaseRepository::SEARCH_FULLTEXT)

      # Should find one instance of 'bat_packages' (defined in just one repository)
      expect(bat_packages.length).to be == 1

      bar_packages = repo.search('bar', Composer::Repository::BaseRepository::SEARCH_FULLTEXT)

      # Should find two instances of 'bar' (defined in just one repository)
      expect(bar_packages.length).to be == 1

      foo_packages = repo.search('foo', Composer::Repository::BaseRepository::SEARCH_FULLTEXT)

      # Should find 'bar'
      expect(foo_packages.length).to be == 2

      platforms = repo.search('platform', Composer::Repository::BaseRepository::SEARCH_FULLTEXT)

      # Should find 'platform'
      expect(platforms.length).to be == 1

    end

    it '#packages succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1'))

      repo = CompositeRepository.new([ hash_repo_1, hash_repo_2 ])
      packages = repo.packages

      # Should get two packages
      expect(packages.length).to be == 2

      # First package should have name of 'foo'
      expect(packages[0].name).to be == 'foo'

      # First package should have pretty version of '1'
      expect(packages[0].pretty_version).to be == '1'

      # Second package should have name of 'bar'
      expect(packages[1].name).to be == 'bar'

      # Second package should have pretty version of '1'
      expect(packages[1].pretty_version).to be == '1'
    end

    it '#count succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1'))

      repo = CompositeRepository.new([ hash_repo_1, hash_repo_2 ])
      expect(repo.count).to be == 2
    end

    it '#remove_package succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1'))
      hash_repo_2.add_package(self.get_package('bar', '2'))
      hash_repo_2.add_package(self.get_package('bar', '3'))

      repo = CompositeRepository.new([ hash_repo_1, hash_repo_2 ])

      expect(repo.count).to be == 4
      repo.remove_package(self.get_package('bar', '3'))
      expect(repo.count).to be == 3
    end

    it '#add_repository succeeds' do
      hash_repo_1 = Composer::Repository::HashRepository.new
      hash_repo_1.add_package(self.get_package('foo', '1'))

      hash_repo_2 = Composer::Repository::HashRepository.new
      hash_repo_2.add_package(self.get_package('bar', '1'))
      hash_repo_2.add_package(self.get_package('bar', '2'))
      hash_repo_2.add_package(self.get_package('bar', '3'))

      repo = CompositeRepository.new([ hash_repo_1 ])
      expect(repo.count).to be == 1
      repo.add_repository(hash_repo_2)
      expect(repo.count).to be == 4
    end

  end

  context 'with no packages' do

    it '#initialize succeeds' do
      repo = CompositeRepository.new([])
      expect(repo.find_packages('foo')).to be == []
      expect(repo.search('foo')).to be == []
      expect(repo.packages).to be == []
      expect(repo.repositories).to be == []
    end

  end
end
