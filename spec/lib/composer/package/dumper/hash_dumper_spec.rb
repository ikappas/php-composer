require_relative '../../../../spec_helper'

describe Composer::Package::Dumper::HashDumper do

  Link = Composer::Package::Link
  VersionConstraint = Composer::Package::LinkConstraint::VersionConstraint

  before do
    @dumper = Composer::Package::Dumper::HashDumper.new()
  end

  it '#dump succeeds with required information' do
      package = Composer::Package::CompletePackage.new('foo', '1.0.0.0', '1.0')
      expected = {
        'name' => 'foo',
        'version' => '1.0',
        'version_normalized' => '1.0.0.0',
        'type' => 'library'
      }
      expect( @dumper.dump(package) ).to be == expected
  end

  it 'RootPackage' do
    package = Composer::Package::RootPackage.new( 'foo', '1.0.0.0', '1.0')
    package.minimum_stability = 'dev'
    config = @dumper.dump(package)
    expect( config['minimum-stability'] ).to be == 'dev'
  end

  it 'DumpAbandoned' do
    package = Composer::Package::CompletePackage.new('foo', '1.0.0.0', '1.0')
    package.abandoned = true
    config = @dumper.dump(package)
    expect( config['abandoned'] ).to be_truthy
  end

  it 'DumpAbandonedReplacement' do
    package = Composer::Package::CompletePackage.new('foo', '1.0.0.0', '1.0')
    package.abandoned = 'foo/bar'
    config = @dumper.dump(package)
    expect( config['abandoned'] ).to be == 'foo/bar'
  end


  it 'Keys' do #($key, $value, $method = null, $expectedValue = null)
    [
      [
        'type',
        'library'
      ],
      [
        'time',
        DateTime.parse('2012-02-01'),
        'release_date',
        '2012-02-01 00:00:00',
      ],
      [
        'authors',
        ['Nils Adermann <naderman@naderman.de>', 'Jordi Boggiano <j.boggiano@seld.be>']
      ],
      [
        'homepage',
        'http://getcomposer.org'
      ],
      [
        'description',
        'Dependency Manager'
      ],
      [
        'keywords',
        ['package', 'dependency', 'autoload'],
        nil,
        ['autoload', 'dependency', 'package']
      ],
      [
        'bin',
        ['bin/composer'],
        'binaries'
      ],
      [
        'license',
        ['MIT']
      ],
      [
        'autoload',
        { 'psr-0' => { 'Composer' => 'src/' } }
      ],
      [
        'repositories',
        { 'packagist' => false }
      ],
      [
        'scripts',
        { 'post-update-cmd' => 'MyVendor\\MyClass::postUpdate' }
      ],
      [
        'extra',
        { 'class' => 'MyVendor\\Installer' }
      ],
      [
        'archive',
        [ '/foo/bar', 'baz', '!/foo/bar/baz' ],
        'archive_excludes',
        { 'exclude' => ['/foo/bar', 'baz', '!/foo/bar/baz'] }
      ],
      [
        'require',
        [ Link.new('foo', 'foo/bar', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0') ],
        'requires',
        { 'foo/bar' => '1.0.0' },
      ],
      [
        'require-dev',
        [ Link.new('foo', 'foo/bar', VersionConstraint.new('=', '1.0.0.0'), 'requires (for development)', '1.0.0') ],
        'dev_requires',
        { 'foo/bar' => '1.0.0' },
      ],
      [
        'suggest',
        { 'foo/bar' => 'very useful package' },
        'suggests'
      ],
      [
        'support',
        { 'foo' => 'bar' },
      ],
      [
        'require',
        [Link.new('foo', 'foo/bar', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0'), Link.new('bar', 'bar/baz', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0')],
        'requires',
        { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      ],
      [
        'require-dev',
        [Link.new('foo', 'foo/bar', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0'), Link.new('bar', 'bar/baz', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0')],
        'dev_requires',
        { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      ],
      [
        'suggest',
        { 'foo/bar' => 'very useful package', 'bar/baz' => 'another useful package' },
        'suggests',
        { 'bar/baz' => 'another useful package', 'foo/bar' => 'very useful package' }
      ],
      [
        'provide',
        [Link.new('foo', 'foo/bar', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0'), Link.new('bar', 'bar/baz', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0')],
        'provides',
        { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      ],
      [
        'replace',
        [Link.new('foo', 'foo/bar', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0'), Link.new('bar', 'bar/baz', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0')],
        'replaces',
        { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      ],
      [
        'conflict',
        [ Link.new('foo', 'foo/bar', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0'), Link.new('bar', 'bar/baz', VersionConstraint.new('=', '1.0.0.0'), 'requires', '1.0.0')],
        'conflicts',
        { 'bar/baz' => '1.0.0', 'foo/bar' => '1.0.0' }
      ],
      [
        'transport-options',
        { 'ssl' => { 'local_cert' => '/opt/certs/test.pem' } },
        'transport_options'
      ]
    ].each do |setup|

      key, value, method, expected_value = setup
      method ||= key
      expected_value ||= value

      package = Composer::Package::CompletePackage.new('foo', '1.0.0.0', '1.0')
      package.send("#{method}=", value)
      package.abandoned = value

      config = @dumper.dump(package)
      expect( config[key] ).to be == expected_value

      # $this->packageExpects('get'.ucfirst($method ?: $key), $value);
      # $this->packageExpects('isAbandoned', $value);

      # $config = $this->dumper->dump($this->package);

      # $this->assertSame($expectedValue ?: $value, $config[$key]);
    end
  end
end
