require_relative '../../../spec_helper'

describe ::Composer::Repository::CompositeRepository do

  context 'with packages' do

    context '#package?' do

      let(:repository) do
        @repository ||= begin
          repo_1 = build( :hash_repository, packages: [
              build( :package, name: 'foo', version: '1' )
          ])
          repo_2 = build( :hash_repository, packages: [
              build( :package, name: 'bar', version: '1' )
          ])
          described_class.new([ repo_1, repo_2 ])
        end
      end

      it "returns true on package 'foo/1'" do
        expect(repository.package?(build(:package, name: 'foo', version: '1'))).to be_truthy
      end

      it "returns true on package 'bar/1'" do
        expect(repository.package?(build(:package, name: 'bar', version: '1'))).to be_truthy
      end

      it "returns false on package 'foo/2'" do
        expect(repository.package?(build(:package, name: 'foo', version: '2'))).to be_falsey
      end

      it "returns false on package 'foo/2'" do
        expect(repository.package?(build(:package, name: 'bar', version: '2'))).to be_falsey
      end

    end

    context '#find_package' do

      let(:repository) do
        @repository ||= begin
          repo_1 = build( :hash_repository, packages: [
              build( :package, name: 'foo', version: '1' )
          ])
          repo_2 = build( :hash_repository, packages: [
              build( :package, name: 'bar', version: '1' )
          ])
          described_class.new([ repo_1, repo_2 ])
        end
      end

      it "finds package 'foo/1' and get name of 'foo'" do
        expect(repository.find_package('foo', '1').name).to be == 'foo'
      end

      it "finds package 'foo/1' and get pretty version of '1'" do
        expect(repository.find_package('foo', '1').pretty_version).to be == '1'
      end

      it "finds package 'bar/1' and get name of 'bar'" do
        expect(repository.find_package('bar', '1').name).to be == 'bar'
      end

      it "finds package 'bar/1' and get pretty version of '1'" do
        expect(repository.find_package('bar', '1').pretty_version).to be == '1'
      end

      it "fails on finding package 'foo/2' and return nil" do
        expect(repository.find_package('foo', '2')).to be_nil
      end

    end

    context '#find_packages' do

      let(:repository) do
        @repository ||= begin
          repo_1 = build( :hash_repository, packages: [
            build( :package, name: 'foo', version: '1' ),
            build( :package, name: 'foo', version: '2' ),
            build( :package, name: 'bat', version: '1' )
          ])
          repo_2 = build( :hash_repository, packages: [
              build( :package, name: 'bar', version: '1' ),
              build( :package, name: 'bar', version: '2' ),
              build( :package, name: 'foo', version: '3' )
          ])
          described_class.new([ repo_1, repo_2 ])
        end
      end

      let(:bat_packages) { @bat_packages ||= repository.find_packages('bat') }
      let(:bar_packages) { @bar_packages ||= repository.find_packages('bar') }
      let(:foo_packages) { @foo_packages ||= repository.find_packages('foo') }

      it "finds one instance of 'bat_packages' (defined in just one repository)" do
        expect(bat_packages.length).to be == 1
      end

      it "finds packages named 'bat'" do
        expect(bat_packages[0].name).to be == 'bat'
      end

      it "finds two instances of 'bar' (both defined in the same repository)" do
        expect(bar_packages.length).to be == 2
      end

      it "finds packages named 'bar'" do
        expect(bar_packages[0].name).to be == 'bar'
        expect(bar_packages[0].pretty_version).to be == '1'
        expect(bar_packages[1].name).to be == 'bar'
        expect(bar_packages[1].pretty_version).to be == '2'
      end

      it "finds three instances of 'foo' (two defined in one repository, the third in the other)" do
        expect(foo_packages.length).to be == 3
      end

      it "finds packages named 'foo'" do
        expect(foo_packages[0].name).to be == 'foo'
        expect(foo_packages[0].pretty_version).to be == '1'
        expect(foo_packages[1].name).to be == 'foo'
        expect(foo_packages[1].pretty_version).to be == '2'
        expect(foo_packages[2].name).to be == 'foo'
        expect(foo_packages[2].pretty_version).to be == '3'
      end

    end

    context '#search' do

      context 'with search name mode' do

        let(:repository) do
          @repository ||= begin
            repo_1 = build( :hash_repository, packages: [
                build( :complete_package, name: 'foo', version: '1' ),
                build( :complete_package, name: 'foo', version: '2' ),
                build( :complete_package, name: 'bat', version: '1' )
            ])
            repo_2 = build( :hash_repository, packages: [
                build( :complete_package, name: 'bar', version: '1' ),
                build( :complete_package, name: 'bar', version: '2' ),
                build( :complete_package, name: 'foo', version: '3' )
            ])
            described_class.new([ repo_1, repo_2 ])
          end
        end

        let(:bat_packages) { @bat_packages ||= repository.search('bat', ::Composer::Repository::BaseRepository::SEARCH_NAME) }
        let(:bar_packages) { @bar_packages ||= repository.search('bar', ::Composer::Repository::BaseRepository::SEARCH_NAME) }
        let(:foo_packages) { @foo_packages ||= repository.search('foo', ::Composer::Repository::BaseRepository::SEARCH_NAME) }

        it "finds one instance of 'bat_packages' (defined in just one repository)" do
          expect(bat_packages.length).to be == 1
        end

        it "finds packages named 'bat'" do
          expect(bat_packages[0]['name']).to be == 'bat'
        end

        it "finds two instances of 'bar' (defined in just one repository)" do
          expect(bar_packages.length).to be == 1
        end

        it "finds packages named 'bar'" do
          expect(bar_packages[0]['name']).to be == 'bar'
        end

        it "finds 'bar'" do
          expect(foo_packages.length).to be == 2
        end

        it "finds packages named 'bar'" do
          expect(foo_packages[0]['name']).to be == 'foo'
          expect(foo_packages[1]['name']).to be == 'foo'
        end

      end

      context 'with search full text mode' do

        let(:repository) do
          @repository ||= begin
            repo_1 = build( :hash_repository, packages: [
                build( :complete_package, name: 'foo', version: '1' ),
                build( :complete_package, name: 'foo', version: '2' ),
                build( :complete_package, name: 'bat', version: '1' )
            ])
            repo_2 = build( :hash_repository, packages: [
                build( :complete_package, name: 'bar', version: '1' ),
                build( :complete_package, name: 'bar', version: '2' ),
            ])

            package = build( :complete_package, name: 'foo', version: '3' )
            allow(package).to receive(:description).and_return( 'sample desc' )
            allow(package).to receive(:keywords).and_return(%w{platform forms})
            repo_2.add_package(package)

            described_class.new([ repo_1, repo_2 ])
          end
        end

        let(:bat_packages) { @bat_packages ||= repository.search('bat', ::Composer::Repository::BaseRepository::SEARCH_FULLTEXT) }
        let(:bar_packages) { @bar_packages ||= repository.search('bar', ::Composer::Repository::BaseRepository::SEARCH_FULLTEXT) }
        let(:foo_packages) { @foo_packages ||= repository.search('foo', ::Composer::Repository::BaseRepository::SEARCH_FULLTEXT) }
        let(:platforms) { @platforms ||= repository.search('platform', ::Composer::Repository::BaseRepository::SEARCH_FULLTEXT) }

        it "finds one instance of 'bat_packages' (defined in just one repository)" do
          expect(bat_packages.length).to be == 1
        end

        it "finds two instances of 'bar' (defined in just one repository)" do
          expect(bar_packages.length).to be == 1
        end

        it "finds 'bar'" do
          expect(foo_packages.length).to be == 2
        end

        it "finds 'platform'" do
          expect(platforms.length).to be == 1
        end

      end
    end

    context '#packages' do

      let(:repository) do
        @repository ||= begin
          repo_1 = build( :hash_repository, packages: [
              build( :package, name: 'foo', version: '1' )
          ])
          repo_2 = build( :hash_repository, packages: [
              build( :package, name: 'bar', version: '1' )
          ])
          described_class.new([ repo_1, repo_2 ])
        end
      end

      it 'contains two packages' do
        expect(repository.packages.length).to be == 2
      end

      it "first package name is 'foo'" do
        expect(repository.packages[0].name).to be == 'foo'
      end

      it "first package pretty version is '1'" do
        expect(repository.packages[0].pretty_version).to be == '1'
      end

      it "second package name is 'bar'" do
        expect(repository.packages[1].name).to be == 'bar'
      end

      it "second package pretty version is '1'" do
        expect(repository.packages[1].pretty_version).to be == '1'
      end

    end

    it '#count succeeds' do

      repo_1 = build( :hash_repository, packages: [
          build( :package, name: 'foo', version: '1' )
      ])
      repo_2 = build( :hash_repository, packages: [
          build( :package, name: 'bar', version: '1' )
      ])

      repository = described_class.new([ repo_1, repo_2 ])
      expect(repository.count).to be == 2

    end

    it '#remove_package succeeds' do

      repo_1 = build( :hash_repository, packages: [
          build( :package, name: 'foo', version: '1' )
      ])

      repo_2 = build( :hash_repository, packages: [
        build( :package, name: 'bar', version: '1' ),
        build( :package, name: 'bar', version: '2' ),
        build( :package, name: 'bar', version: '3' )
      ])

      repository = described_class.new([ repo_1, repo_2 ])
      expect(repository.count).to be == 4
      repository.remove_package(build( :package, name: 'bar', version: '3' ))
      expect(repository.count).to be == 3
    end

    it '#add_repository succeeds' do

      repo_1 = build( :hash_repository, packages: [
          build( :package, name: 'foo', version: '1' )
      ])

      repo_2 = build( :hash_repository, packages: [
          build( :package, name: 'bar', version: '1' ),
          build( :package, name: 'bar', version: '2' ),
          build( :package, name: 'bar', version: '3' )
      ])

      repository = described_class.new([ repo_1 ])
      expect(repository.count).to be == 1
      repository.add_repository(repo_2)
      expect(repository.count).to be == 4
    end

  end

  context 'with no packages' do

    it '#initialize succeeds' do
      repository = described_class.new([])
      expect(repository.find_packages('foo')).to be == []
      expect(repository.search('foo')).to be == []
      expect(repository.packages).to be == []
      expect(repository.repositories).to be == []
    end

  end

end
