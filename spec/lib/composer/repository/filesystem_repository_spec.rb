require_relative '../../../spec_helper'

describe ::Composer::Repository::FilesystemRepository do

  let(:json_file) do
    @json_file ||= begin
      json_file = double(::Composer::Json::JsonFile)
      allow(json_file).to receive(:is_a?).once.and_return( true )
      json_file
    end
  end

  let(:repository) { @repository ||= described_class.new(json_file) }

  it '#read succeeds' do
    expect(json_file).to receive(:exists?).once.and_return( true )
    expect(json_file).to receive(:read).once.and_return([
      {
        'name' => 'package1',
        'version'=> '1.0.0-beta',
        'type' => 'vendor'
      }
    ])

    packages = repository.packages
    expect(packages.length).to be == 1
    expect(packages[0].name).to be == 'package1'
    expect(packages[0].version).to be == '1.0.0.0-beta'
    expect(packages[0].type).to be == 'vendor'
  end

  context '#packages' do

    context 'with corrupted repository file' do
      it 'raises invalid repository error' do
        expect(json_file).to receive(:read).once.and_return( 'foo' )
        expect(json_file).to receive(:exists?).once.and_return( true )
        expect(json_file).to receive(:path).once.and_return( 'test\path' )
        expect { repository.packages }.to raise_error(::Composer::InvalidRepositoryError)
      end
    end

    context 'with non-existent repository file' do
      it 'returns empty array' do
        expect(json_file).to receive(:exists?).once.and_return( false )
        expect(repository.packages).to be == []
      end
    end
  end

  it '#write succeeds' do
    expect(json_file).to receive(:read).once.and_return([])
    expect(json_file).to receive(:exists?).once.and_return( true )
    expect(json_file).to receive(:write).once.with([
      { 'name' => 'mypkg', 'type' => 'library', 'version' => '0.1.10', 'version_normalized' => '0.1.10.0' }
    ])

    repository.add_package(build(:package, name: 'mypkg', version: '0.1.10'))
    repository.write
  end

  it '#reload succeeds' do
    expect(json_file).to receive(:exists?).twice.and_return( true )
    expect(json_file).to receive(:read).twice.and_return([
      {
        'name' => 'package1',
        'version'=> '1.0.0-beta',
        'type' => 'vendor'
      }
    ])

    packages1 = repository.packages
    repository.reload
    packages2 = repository.packages

    expect(packages2.length).to be ==  packages1.length
    expect(packages2[0].name).to be == packages1[0].name
    expect(packages2[0].version).to be == packages1[0].version
    expect(packages2[0].type).to be == packages1[0].type
  end

end
