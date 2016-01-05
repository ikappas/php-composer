require_relative '../../../../spec_helper'

describe ::Composer::Package::Version::VersionSelector do

  let(:pool) { nil }
  let(:selector) { described_class.new(pool)}
  let(:parser) { ::Composer::Semver::VersionParser.new }

  context '#find_recommended_require_version' do
    [
      # real version, is dev package, stability, expected recommendation, [branch-alias]
      { pretty_version: '1.2.1',        is_dev: false, stability: 'stable', expected_version: '~1.2' },
      { pretty_version: '1.2',          is_dev: false, stability: 'stable', expected_version: '~1.2' },
      { pretty_version: 'v1.2.1',       is_dev: false, stability: 'stable', expected_version: '~1.2' },
      { pretty_version: '3.1.2-pl2',    is_dev: false, stability: 'stable', expected_version: '~3.1' },
      { pretty_version: '3.1.2-patch',  is_dev: false, stability: 'stable', expected_version: '~3.1' },
      { pretty_version: '0.1.0',        is_dev: false, stability: 'stable', expected_version: '0.1.*' },
      { pretty_version: '0.1.3',        is_dev: false, stability: 'stable', expected_version: '0.1.*' },
      { pretty_version: '0.0.3',        is_dev: false, stability: 'stable', expected_version: '0.0.3.*' },
      { pretty_version: '0.0.3-alpha',  is_dev: false, stability: 'alpha',  expected_version: '0.0.3.*@alpha' },
      { pretty_version: '2.0-beta.1',   is_dev: false, stability: 'beta',   expected_version: '~2.0@beta' },
      { pretty_version: '3.1.2-alpha5', is_dev: false, stability: 'alpha',  expected_version: '~3.1@alpha' },
      { pretty_version: '3.0-RC2',      is_dev: false, stability: 'RC',     expected_version: '~3.0@RC' },
      # date-based versions are not touched at all
      { pretty_version: 'v20121020',    is_dev: false, stability: 'stable', expected_version: 'v20121020' },
      { pretty_version: 'v20121020.2',  is_dev: false, stability: 'stable', expected_version: 'v20121020.2' },
      # dev packages without alias are not touched at all
      { pretty_version: 'dev-master',   is_dev: true,  stability: 'dev',    expected_version: 'dev-master' },
      { pretty_version: '3.1.2-dev',    is_dev: true,  stability: 'dev',    expected_version: '3.1.2-dev' },
      # dev packages with alias inherit the alias
      { pretty_version: 'dev-master',   is_dev: true,  stability: 'dev',    expected_version: '~2.1@dev', branch_alias: '2.1.x-dev' },
      { pretty_version: 'dev-master',   is_dev: true,  stability: 'dev',    expected_version: '~2.1@dev', branch_alias: '2.1-dev' },
      { pretty_version: 'dev-master',   is_dev: true,  stability: 'dev',    expected_version: '~2.1@dev', branch_alias: '2.1.3.x-dev' },
      { pretty_version: 'dev-master',   is_dev: true,  stability: 'dev',    expected_version: '~2.0@dev', branch_alias: '2.x-dev' },
      # // numeric alias
      { pretty_version: '3.x-dev',      is_dev: true,  stability: 'dev',    expected_version: '~3.0@dev', branch_alias: '3.0.x-dev' },
      { pretty_version: '3.x-dev',      is_dev: true,  stability: 'dev',    expected_version: '~3.0@dev', branch_alias: '3.0-dev' }
    ].each do |test|

      branch_alias_desc = test[:branch_alias] ? " with branch alias #{test[:branch_alias]}" : ''

      it "succeeds on '#{test[:pretty_version]}'#{ branch_alias_desc }" do
        package = double('Composer::Package::Package')
        allow(package).to receive(:pretty_name).and_return( 'Pretty Name' )
        allow(package).to receive(:pretty_version).and_return( test[:pretty_version] )
        allow(package).to receive(:version).and_return( parser.normalize(test[:pretty_version]) )
        allow(package).to receive(:is_dev?).and_return( test[:is_dev] )
        allow(package).to receive(:stability).and_return( test[:stability] )
        allow(package).to receive(:target_dir).and_return( nil )
        allow(package).to receive(:source_type).and_return( nil )
        allow(package).to receive(:dist_type).and_return( nil )
        allow(package).to receive(:archive_excludes).and_return( nil )
        allow(package).to receive(:requires).and_return( nil )
        allow(package).to receive(:conflicts).and_return( nil )
        allow(package).to receive(:provides).and_return( nil )
        allow(package).to receive(:replaces).and_return( nil )
        allow(package).to receive(:dev_requires).and_return( nil )
        allow(package).to receive(:suggests).and_return( nil )
        allow(package).to receive(:requires).and_return( nil )
        allow(package).to receive(:release_date).and_return( nil )
        allow(package).to receive(:binaries).and_return( nil )
        allow(package).to receive(:type).and_return( nil )
        allow(package).to receive(:installation_source).and_return( nil )
        allow(package).to receive(:autoload).and_return( nil )
        allow(package).to receive(:dev_autoload).and_return( nil )
        allow(package).to receive(:notification_url).and_return( nil )
        allow(package).to receive(:include_paths).and_return( nil )
        allow(package).to receive(:transport_options).and_return( nil )

        branch_alias = !test.key?(:branch_alias) ? [] : { 'branch-alias' => { test[:pretty_version] => test[:branch_alias] }}
        allow(package).to receive(:extra).and_return( branch_alias )

        expect( selector.find_recommended_require_version(package) ).to be == test[:expected_version]
      end
    end
  end
end
