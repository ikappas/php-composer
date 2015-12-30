require_relative '../../../spec_helper'

describe ::Composer::Repository::HashRepository do

  context '#initialize' do

    it 'succeeds on empty array' do
      repo = build( :hash_repository, packages: [])
      expect(repo.count).to be == 0
    end

    it 'succeeds on array of packages' do
      repo = build( :hash_repository, packages: [
          build( :package, name: 'foo', version: '1')
      ])
      expect(repo.count).to be == 1
    end

  end

  it '#add_package succeeds' do
    repo = build( :hash_repository, :empty )
    repo.add_package( build( :package, name: 'foo', version: '1'))
    expect(repo.count).to be == 1
  end

  it '#remove_package succeeds' do
    package =  build( :package, name: 'bar', version: '2')
    repo = build( :hash_repository, :empty )
    repo.add_package( build( :package, name: 'foo', version: '1'))
    repo.add_package(package)

    expect(repo.count).to be == 2
    repo.remove_package( build( :package, name: 'foo', version: '1'))
    expect(repo.count).to be == 1
    expect(repo.packages).to be == [ package ]
  end

  it '#package? succeeds' do
    repo = build( :hash_repository, packages: [
      build( :package, name: 'foo', version: '1'),
      build( :package, name: 'bar', version: '2')
    ])

    expect(repo.package?( build( :package, name: 'foo', version: '1'))).to be true
    expect(repo.package?( build( :package, name: 'bar', version: '1'))).to be false
  end

  it '#find_packages succeeds' do
    repo = build( :hash_repository, packages: [
      build( :package, name: 'foo', version: '1'),
      build( :package, name: 'bar', version: '2'),
      build( :package, name: 'bar', version: '3'),
    ])

    foo = repo.find_packages('foo')
    expect(foo.length).to be == 1
    expect(foo[0].name).to be == 'foo'

    bar = repo.find_packages('bar')
    expect(bar.length).to be == 2
    expect(bar[0].name).to be == 'bar'
  end

  it '#search succeeds' do
    repo = build( :hash_repository, packages: [
      build( :complete_package, name: 'foo', version: '1' ),
      build( :complete_package, name: 'bar', version: '2' ),
      build( :complete_package, name: 'bar', version: '3' )
    ])

    foo = repo.search('foo')
    expect(foo.length).to be == 1
    expect(foo[0]['name']).to be == 'foo'
  end

  it 'automatically adds aliased package' do
    repo = build( :hash_repository, :empty)
    package =  build( :package, name: 'foo', version: '1')
    alias_package = build( :alias_package, alias_of: package, version: '2' )

    repo.add_package(alias_package)

    expect(repo.count).to be == 2
    expect(repo.package?( build( :package, name: 'foo', version: '1'))).to be true
    expect(repo.package?( build( :package, name: 'foo', version: '2'))).to be true
  end

end
