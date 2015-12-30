require_relative '../../../spec_helper'

describe ::Composer::Package::AliasPackage do

  let(:package){ build :complete_package, name: 'foo', version: '1.0' }
  let(:alias_package){ build :alias_package, alias_of: package, version: '2.0' }

  [
      :type,
      :target_dir,
      :extra,
      :installation_source,
      :source_type,
      :source_url,
      :source_urls,
      :source_reference,
      :source_mirrors,
      :dist_type,
      :dist_url,
      :dist_urls,
      :dist_reference,
      :dist_sha1_checksum,
      :transport_options,
      :dist_mirrors,
      :scripts,
      :license,
      :autoload,
      :dev_autoload,
      :include_paths,
      :repositories,
      :release_date,
      :binaries,
      :keywords,
      :description,
      :homepage,
      :suggests,
      :authors,
      :support,
      :notification_url,
      :archive_excludes,
      :abandoned?,
      :replacement_package

  ].each do |method|

    context ".#{method}" do

      it 'should forward all calls to the aliased package' do
        allow(package).to receive(method).twice.and_return(true)
        expect( alias_package.send(method) ).to be == package.send(method)
      end

    end

    # {
    #
    #     :installation_source= => type,
    #     :source_reference= => reference,
    #     :source_mirrors= => mirrors,
    #     :dist_reference= => reference,
    #     :transport_options= => options,
    #     :dist_mirrors= => mirrors,
    #
    # }.each do |method|
    #
    # end

  end

end
