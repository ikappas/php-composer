require 'spec_helper'

describe Composer::Repository::FilesystemRepository do

  FilesystemRepository = Composer::Repository::FilesystemRepository

  it '#read succeeds' do
    json = double(Composer::Json::JsonFile)
    allow(json).to receive(:is_a?).once.and_return( true )
    repo = FilesystemRepository.new(json)

    expect(json).to receive(:exists?).once.and_return( true )
    expect(json).to receive(:read).once.and_return([
      {
        'name' => 'package1',
        'version'=> '1.0.0-beta',
        'type' => 'vendor'
      }
    ])

    packages = repo.packages

    expect(packages.length).to be == 1
    expect(packages[0].name).to be == 'package1'
    expect(packages[0].version).to be == '1.0.0.0-beta'
    expect(packages[0].type).to be == 'vendor'

  end

  it '#packages with corrupted repository file' do
    json = double(Composer::Json::JsonFile)
    allow(json).to receive(:is_a?).once.and_return( true )

    repo = FilesystemRepository.new(json)
    expect(json).to receive(:read).once.and_return( 'foo' )
    expect(json).to receive(:exists?).once.and_return( true )
    expect(json).to receive(:path).once.and_return( 'test\path' )

    expect { repo.packages }.to raise_error(Composer::InvalidRepositoryError)
  end

  it '#packages with non-existent repository file' do
    json = double(Composer::Json::JsonFile)
    allow(json).to receive(:is_a?).once.and_return( true )

    repo = FilesystemRepository.new(json)
    expect(json).to receive(:exists?).once.and_return( false )
    expect(repo.packages).to be == []
  end

  it '#write succeeds' do
    json = double(Composer::Json::JsonFile)
    allow(json).to receive(:is_a?).once.and_return( true )

    repo = FilesystemRepository.new(json)

    expect(json).to receive(:read).once.and_return([])
    expect(json).to receive(:exists?).once.and_return( true )
    expect(json).to receive(:write).once.with([
      { 'name' => 'mypkg', 'type' => 'library', 'version' => '0.1.10', 'version_normalized' => '0.1.10.0' }
    ])

    repo.add_package(self.get_package('mypkg', '0.1.10'))
    repo.write
  end

  it '#reload succeeds' do

    json = double(Composer::Json::JsonFile)
    allow(json).to receive(:is_a?).once.and_return( true )
    repo = FilesystemRepository.new(json)

    expect(json).to receive(:exists?).twice.and_return( true )
    expect(json).to receive(:read).twice.and_return([
      {
        'name' => 'package1',
        'version'=> '1.0.0-beta',
        'type' => 'vendor'
      }
    ])

    packages1 = repo.packages
    repo.reload
    packages2 = repo.packages

    expect(packages2.length).to be ==  packages1.length
    expect(packages2[0].name).to be == packages1[0].name
    expect(packages2[0].version).to be == packages1[0].version
    expect(packages2[0].type).to be == packages1[0].type
  end

end
