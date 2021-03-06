require_relative '../../../spec_helper'

describe ::Composer::Package::CompletePackage do

  let(:providers) do
    @providers ||= [
      { name: 'foo',            version: '1-beta' },
      { name: 'node',           version: '0.5.6' },
      { name: 'li3',            version: '0.10' },
      { name: 'mongodb_odm',    version: '1.0.0BETA3' },
      { name: 'DoctrineCommon', version: '2.2.0-DEV' }
    ]
  end

  let(:version_parser) { ::Composer::Semver::VersionParser.new }

  it 'has expected naming semantics' do
    providers.each do |provider|
      name = provider[:name]
      version = provider[:version]
      norm_version = version_parser.normalize(version)
      package = described_class.new(name, norm_version, version)
      expect(package.name).to be == name.downcase
    end
  end

  it 'has expected versioning semantics' do
    providers.each do |provider|
      name = provider[:name]
      version = provider[:version]
      norm_version = version_parser.normalize(version)
      package = described_class.new(name, norm_version, version)
      expect(package.pretty_version).to be == version
      expect(package.version).to be == norm_version
    end
  end

  it 'has expected marshalling semantics' do
    providers.each do |provider|
      name = provider[:name]
      version = provider[:version]
      norm_version = version_parser.normalize(version)
      package = described_class.new(name, norm_version, version)
      expect(package.pretty_version).to be == version
      expect("#{package}").to be == "#{name.downcase}-#{norm_version}"
    end
  end

  it 'has expected target dir' do
    package = described_class.new('a', '1.0.0.0', '1.0')

    expect(package.target_dir).to be_nil

    package.target_dir = './../foo/'
    expect(package.target_dir).to be == 'foo/'

    package.target_dir = 'foo/../../../bar/'
    expect(package.target_dir).to be == 'foo/bar/'

    package.target_dir = '../..'
    expect(package.target_dir).to be == ''

    package.target_dir = '..'
    expect(package.target_dir).to be == ''

    package.target_dir = '/..'
    expect(package.target_dir).to be == ''

    package.target_dir = '/foo/..'
    expect(package.target_dir).to be == 'foo/'

    package.target_dir = '/foo/..//bar'
    expect(package.target_dir).to be == 'foo/bar'
  end

end
