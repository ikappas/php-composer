require 'spec_helper'

describe Composer::Repository::CompositeRepository do

  CompositeRepository = Composer::Repository::CompositeRepository

  context 'with packages' do

    it '#package? succeeds' do
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1'))

      repo = CompositeRepository.new([ hashRepoOne, hashRepoTwo ])

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
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1'))

      repo = CompositeRepository.new([ hashRepoOne, hashRepoTwo ])

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
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1'))
      hashRepoOne.add_package(self.get_package('foo', '2'))
      hashRepoOne.add_package(self.get_package('bat', '1'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1'))
      hashRepoTwo.add_package(self.get_package('bar', '2'))
      hashRepoTwo.add_package(self.get_package('foo', '3'))

      repo = CompositeRepository.new([ hashRepoOne, hashRepoTwo ])

      bats = repo.find_packages('bat')

      # Should find one instance of 'bats' (defined in just one repository)
      expect(bats.length).to be == 1

      # "Should find packages named 'bat'"
      expect(bats[0].name).to be == 'bat'

      bars = repo.find_packages('bar')

      # Should find two instances of 'bar' (both defined in the same repository)
      expect(bars.length).to be == 2

      # Should find packages named 'bar'
      expect(bars[0].name).to be == 'bar'
      expect(bars[0].pretty_version).to be == '1'
      expect(bars[1].name).to be == 'bar'
      expect(bars[1].pretty_version).to be == '2'

      foos = repo.find_packages('foo')

      # Should find three instances of 'foo' (two defined in one repository, the third in the other)
      expect(foos.length).to be == 3

      # Should find packages named 'foo'
      expect(foos[0].name).to be == 'foo'
      expect(foos[0].pretty_version).to be == '1'
      expect(foos[1].name).to be == 'foo'
      expect(foos[1].pretty_version).to be == '2'
      expect(foos[2].name).to be == 'foo'
      expect(foos[2].pretty_version).to be == '3'
    end

    it '#search with search name mode  succeeds' do
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1', 'Composer::Package::CompletePackage'))
      hashRepoOne.add_package(self.get_package('foo', '2', 'Composer::Package::CompletePackage'))
      hashRepoOne.add_package(self.get_package('bat', '1', 'Composer::Package::CompletePackage'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1', 'Composer::Package::CompletePackage'))
      hashRepoTwo.add_package(self.get_package('bar', '2', 'Composer::Package::CompletePackage'))
      hashRepoTwo.add_package(self.get_package('foo', '3', 'Composer::Package::CompletePackage'))

      repo = CompositeRepository.new([ hashRepoOne, hashRepoTwo ])

      bats = repo.search('bat', Composer::Repository::BaseRepository::SEARCH_NAME)

      # Should find one instance of 'bats' (defined in just one repository)
      expect(bats.length).to be == 1

      # Should find packages named 'bat'"
      expect(bats[0]['name']).to be == 'bat'

      bars = repo.search('bar', Composer::Repository::BaseRepository::SEARCH_NAME)

      # Should find two instances of 'bar' (defined in just one repository)
      expect(bars.length).to be == 1

      # Should find packages named 'bar'
      expect(bars[0]['name']).to be == 'bar'

      foos = repo.search('foo', Composer::Repository::BaseRepository::SEARCH_NAME)

      # Should find 'bar'
      expect(foos.length).to be == 2

      # Should find packages named 'bar'
      expect(foos[0]['name']).to be == 'foo'
      expect(foos[1]['name']).to be == 'foo'

    end

    it '#search with search full text mode  succeeds' do
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1', 'Composer::Package::CompletePackage'))
      hashRepoOne.add_package(self.get_package('foo', '2', 'Composer::Package::CompletePackage'))
      hashRepoOne.add_package(self.get_package('bat', '1', 'Composer::Package::CompletePackage'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1', 'Composer::Package::CompletePackage'))
      hashRepoTwo.add_package(self.get_package('bar', '2', 'Composer::Package::CompletePackage'))
      packageTwo = self.get_package('foo', '3', 'Composer::Package::CompletePackage')
      allow(packageTwo).to receive(:description).and_return( 'sample desc' )
      allow(packageTwo).to receive(:keywords).and_return(%w{platform forms})
      hashRepoTwo.add_package(packageTwo)


      repo = CompositeRepository.new([ hashRepoOne, hashRepoTwo ])

      bats = repo.search('bat', Composer::Repository::BaseRepository::SEARCH_FULLTEXT)

      # Should find one instance of 'bats' (defined in just one repository)
      expect(bats.length).to be == 1

      bars = repo.search('bar', Composer::Repository::BaseRepository::SEARCH_FULLTEXT)

      # Should find two instances of 'bar' (defined in just one repository)
      expect(bars.length).to be == 1

      foos = repo.search('foo', Composer::Repository::BaseRepository::SEARCH_FULLTEXT)

      # Should find 'bar'
      expect(foos.length).to be == 2

      platforms = repo.search('platform', Composer::Repository::BaseRepository::SEARCH_FULLTEXT)

      # Should find 'platform'
      expect(platforms.length).to be == 1

    end

    it '#packages succeeds' do
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1'))

      repo = CompositeRepository.new([ hashRepoOne, hashRepoTwo ])
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
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1'))

      repo = CompositeRepository.new([ hashRepoOne, hashRepoTwo ])
      expect(repo.count).to be == 2
    end

    it '#remove_package succeeds' do
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1'))
      hashRepoTwo.add_package(self.get_package('bar', '2'))
      hashRepoTwo.add_package(self.get_package('bar', '3'))

      repo = CompositeRepository.new([ hashRepoOne, hashRepoTwo ])

      expect(repo.count).to be == 4
      repo.remove_package(self.get_package('bar', '3'))
      expect(repo.count).to be == 3
    end

    it '#add_repository succeeds' do
      hashRepoOne = Composer::Repository::HashRepository.new
      hashRepoOne.add_package(self.get_package('foo', '1'))

      hashRepoTwo = Composer::Repository::HashRepository.new
      hashRepoTwo.add_package(self.get_package('bar', '1'))
      hashRepoTwo.add_package(self.get_package('bar', '2'))
      hashRepoTwo.add_package(self.get_package('bar', '3'))

      repo = CompositeRepository.new([ hashRepoOne ])
      expect(repo.count).to be == 1
      repo.add_repository(hashRepoTwo)
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
