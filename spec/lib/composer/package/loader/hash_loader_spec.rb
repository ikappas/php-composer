require_relative '../../../../spec_helper'

describe Composer::Package::Loader::HashLoader do

  before do
    @loader = Composer::Package::Loader::HashLoader.new(nil, true)
  end

  it '#load succeeds setting package self version' do
    config = {
      'name' => 'A',
      'version' => '1.2.3.4',
      'replace' => {
        'foo' => 'self.version'
      }
    }
    package = @loader.load(config)
    replaces = package.replaces
    expect(String(replaces['foo'].constraint)).to be == '== 1.2.3.4'
  end

  it '#load succeeds setting package default type' do
    config = {
      'name' => 'A',
      'version' => '1.0'
    }
    package = @loader.load(config)
    expect(package.type).to be == 'library'

    config = {
      'name' => 'A',
      'version' => '1.0',
      'type' => 'foo'
    }
    package = @loader.load(config)
    expect(package.type).to be == 'foo'
  end

  it '#load succeeds normalized version optimization' do
    config = {
      'name' => 'A',
      'version' => '1.2.3'
    }
    package = @loader.load(config)
    expect(package.version).to be == '1.2.3.0'

    config = {
      'name' => 'A',
      'version' => '1.2.3',
      'version_normalized' => '1.2.3.4'
    }
    package = @loader.load(config)
    expect(package.version).to be == '1.2.3.4'
  end

  it '#load succeeds parse -> dump' do
    config = {
      'name' => 'A/B',
      'version' => '1.2.3',
      'version_normalized' => '1.2.3.0',
      'description' => 'Foo bar',
      'type' => 'library',
      'keywords' => %w{a b c},
      'homepage' => 'http://example.com',
      'license' => %w{MIT GPLv3},
      'authors' => [
        { 'name' => 'Bob', 'email' => 'bob@example.org', 'homepage' => 'example.org', 'role' => 'Developer' },
      ],
      'require' => {
        'foo/bar' => '1.0',
      },
      'require-dev' => {
        'foo/baz' => '1.0',
      },
      'replace' => {
        'foo/qux' => '1.0',
      },
      'conflict' => {
        'foo/quux' => '1.0',
      },
      'provide' => {
        'foo/quuux' => '1.0',
      },
      'autoload' => {
        'psr-0' => {
          'Ns\Prefix' => 'path'
        },
        'classmap' => [ 'path', 'path2' ],
      },
      'include-path' => ['path3', 'path4'],
      'target-dir' => 'some/prefix',
      'extra' => {
        'random' => {
          'things' => 'of',
          'any' => 'shape'
        }
      },
      'bin' => [ '/bin1', 'bin/foo' ],
      'archive' => {
        'exclude' => [ '/foo/bar', 'baz', '!/foo/bar/baz' ],
      },
      'transport-options' => {
        'ssl' => {
          'local_cert' => '/opt/certs/test.pem'
        }
      },
      'abandoned' => 'foo/bar'
    }

    package = @loader.load(config)
    dumper = Composer::Package::Dumper::HashDumper.new
    expect(dumper.dump(package)).to be == config
  end

  it '#load succeeds on packages with branch alias' do
    config = {
      'name' => 'A',
      'version' => 'dev-master',
      'extra' => {
        'branch-alias' => {
          'dev-master' => '1.0.x-dev'
        }
      }
    }
    package = @loader.load(config)
    expect(package).to be_a Composer::Package::AliasPackage
    expect(package.pretty_version).to be == '1.0.x-dev'

    config = {
      'name' => 'A',
      'version' => 'dev-master',
      'extra' => {
        'branch-alias' => {
          'dev-master' => '1.0-dev'
        }
      }
    }
    package = @loader.load(config)
    expect(package).to be_a Composer::Package::AliasPackage
    expect(package.pretty_version).to be == '1.0.x-dev'

    config = {
      'name' => 'B',
      'version' => '4.x-dev',
      'extra' => {
        'branch-alias' => {
          '4.x-dev' => '4.0.x-dev'
        }
      }
    }
    package = @loader.load(config)
    expect(package).to be_a Composer::Package::AliasPackage
    expect(package.pretty_version).to be == '4.0.x-dev'

    config = {
      'name' => 'B',
      'version' => '4.x-dev',
      'extra' => {
        'branch-alias' => {
          '4.x-dev' => '4.0-dev'
        }
      }
    }
    package = @loader.load(config)
    expect(package).to be_a Composer::Package::AliasPackage
    expect(package.pretty_version).to be == '4.0.x-dev'

    config = {
      'name' => 'C',
      'version' => '4.x-dev',
      'extra' => {
        'branch-alias' => {
          '4.x-dev' => '3.4.x-dev'
        }
      }
    }
    package = @loader.load(config)
    expect(package).to be_a Composer::Package::CompletePackage
    expect(package.pretty_version).to be == '4.x-dev'
  end

  it '#load succeeds setting abandoned' do
    config = {
      'name' => 'A',
      'version' => '1.2.3.4',
      'abandoned' => 'foo/bar'
    }
    package = @loader.load(config)
    expect(package.is_abandoned?).to be_truthy
    expect(package.replacement_package).to be == 'foo/bar'
  end

  it '#load succeeds setting not abandoned' do
    config = {
      'name' => 'A',
      'version' => '1.2.3.4'
    }
    package = @loader.load(config)
    expect(package.is_abandoned?).to be_falsey
  end
end
