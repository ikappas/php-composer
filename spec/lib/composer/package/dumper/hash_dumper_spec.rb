require_relative '../../../../spec_helper'

describe ::Composer::Package::Dumper::HashDumper do

  let(:dumper) { @dumper ||= described_class.new }

  context '#dump' do

    it 'succeeds on dumping required information' do
      package = double( ::Composer::Package::CompletePackage )
      expect(package).to receive(:pretty_name).once.and_return 'foo'
      expect(package).to receive(:pretty_version).once.and_return '1.0'
      expect(package).to receive(:version).once.and_return '1.0.0.0'

      expected = {
        'name' => 'foo',
        'version' => '1.0',
        'version_normalized' => '1.0.0.0'
      }
      expect( dumper.dump(package) ).to be == expected
    end

    it 'succeeds on dumping root package' do
      package = build(:root_package, name: 'foo', version: '1.0')
      package.minimum_stability = 'dev'
      config = dumper.dump(package)
      expect( config['minimum-stability'] ).to be == 'dev'
    end

    it 'succeeds on dumping abandoned' do
      package = build(:complete_package, name: 'foo', version: '1.0')
      package.abandoned = true
      config = dumper.dump(package)
      expect( config['abandoned'] ).to be_truthy
    end

    it 'succeeds on dumping abandoned replacement' do
      package = build(:complete_package, name: 'foo', version: '1.0')
      package.abandoned = 'foo/bar'
      config = dumper.dump(package)
      expect( config['abandoned'] ).to be == 'foo/bar'
    end

    [
      {
        key: 'type',
        value: 'library'
      },
      {
        key: 'time',
        value: DateTime.parse('2012-02-01'),
        method: 'release_date',
        expected: '2012-02-01 00:00:00',
      },
      {
        key: 'authors',
        value: ['Nils Adermann <naderman@naderman.de>', 'Jordi Boggiano <j.boggiano@seld.be>']
      },
      {
        key: 'homepage',
        value: 'http://getcomposer.org'
      },
      {
        key: 'description',
        value: 'Dependency Manager'
      },
      {
        key: 'keywords',
        value: %w(package dependency autoload),
        expected: %w(autoload dependency package)
      },
      {
        key: 'bin',
        value: ['bin/composer'],
        method: 'binaries'
      },
      {
        key: 'license',
        value: ['MIT']
      },
      {
        key: 'autoload',
        value: { 'psr-0' => { 'Composer' => 'src/' } }
      },
      {
        key: 'repositories',
        value: { 'packagist' => false }
      },
      {
        key: 'scripts',
        value: { 'post-update-cmd' => 'MyVendor\\MyClass::postUpdate' }
      },
      {
        key: 'extra',
        value: { 'class' => 'MyVendor\\Installer' }
      },
      {
        key: 'archive',
        value: [ '/foo/bar', 'baz', '!/foo/bar/baz' ],
        method: 'archive_excludes',
        expected: { 'exclude' => ['/foo/bar', 'baz', '!/foo/bar/baz'] }
      },
      {
        key: 'require',
        value: [ FactoryGirl.build(:link, :foo) ],
        method: 'requires',
        expected: { 'foo/bar' => '1.0.0' },
      },
      {
        key: 'require-dev',
        value: [ FactoryGirl.build(:link, :foo) ],
        method: 'dev_requires',
        expected: { 'foo/bar' => '1.0.0' },
      },
      {
        key: 'suggest',
        value: { 'foo/bar' => 'very useful package' },
        method: 'suggests'
      },
      {
        key: 'support',
        value: { 'foo' => 'bar' },
      },
      {
        key: 'require',
        value: [ FactoryGirl.build(:link, :foo), FactoryGirl.build(:link, :bar) ],
        method: 'requires',
        expected: { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      },
      {
        key: 'require-dev',
        value: [ FactoryGirl.build(:link, :foo), FactoryGirl.build(:link, :bar) ],
        method: 'dev_requires',
        expected: { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      },
      {
        key: 'suggest',
        value: { 'foo/bar' => 'very useful package', 'bar/baz' => 'another useful package' },
        method: 'suggests',
        expected: { 'bar/baz' => 'another useful package', 'foo/bar' => 'very useful package' }
      },
      {
        key: 'provide',
        value: [ FactoryGirl.build(:link, :foo), FactoryGirl.build(:link, :bar) ],
        method: 'provides',
        expected: { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      },
      {
        key: 'replace',
        value: [ FactoryGirl.build(:link, :foo), FactoryGirl.build(:link, :bar) ],
        method: 'replaces',
        expected: { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      },
      {
        key: 'conflict',
        value: [ FactoryGirl.build(:link, :foo), FactoryGirl.build(:link, :bar) ],
        method: 'conflicts',
        expected: { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      },
      {
        key: 'transport-options',
        value: { 'ssl' => { 'local_cert' => '/opt/certs/test.pem' } },
        method: 'transport_options'
      }

    ].each do |test|
      it "succeeds on dumping '#{test[:key]}'" do

        key, value, method, expected = test[:key], test[:value], test[:method], test[:expected]
        method ||= key
        expected ||= value

        package = build( :complete_package, name: 'foo', version: '1.0')
        package.send("#{method}=", value)
        package.abandoned = value

        config = dumper.dump(package)
        expect( config[key] ).to be == expected

      end
    end
  end
end
