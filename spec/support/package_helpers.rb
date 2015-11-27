require_relative '../spec_helper'

module PackageHelpers
  extend self

  def instance_base_package(setup)
    package = double(Composer::Package::BasePackage)
    package = base_package_methods(package, setup)
    package
  end

  def instance_package(setup)
    package = double('Composer::Package::Package')
    package = base_package_methods(package, setup)
    package = package_methods(package, setup)
    package
  end

  def instance_complete_package(setup)
    package = double('Composer::Package::CompletePackage')
    package = base_package_methods(package, setup)
    package = package_methods(package, setup)
    package = complete_package_methods(package, setup)
    package
  end

  def instance_root_package(setup)
    package = double(Composer::Package::RootPackage)
    package = base_package_methods(package, setup)
    package = package_methods(package, setup)
    package = complete_package_methods(package, setup)
    package = root_package_methods(package, setup)
    package
  end

  def base_package_methods(package, setup)
    allow(package).to receive(:id).and_return( setup.key?(:id) ? setup[:id] : -1 )
    allow(package).to receive(:repository).and_return( setup.key?(:repository) ? setup[:repository] : nil )
    allow(package).to receive(:transport_options).and_return( setup.key?(:transport_options) ? setup[:transport_options] : [] )
    allow(package).to receive(:name).and_return( setup.key?(:name) ? setup[:name] : nil )
    allow(package).to receive(:pretty_name).and_return( setup.key?(:pretty_name) ? setup[:pretty_name] : nil )
    allow(package).to receive(:version).and_return( setup.key?(:version) ? setup[:version] : nil )
    allow(package).to receive(:pretty_version).and_return( setup.key?(:pretty_version) ? setup[:pretty_version] : nil )
    allow(package).to receive(:stability).and_return( setup.key?(:stability) ? setup[:stability] : nil )
    allow(package).to receive(:type).and_return( setup.key?(:type) ? setup[:type] : 'library' )
    allow(package).to receive(:unique_name).and_return( "#{setup[:name]}-#{setup['version']}" )
    allow(package).to receive(:pretty_string).and_return( "#{setup[:pretty_name]}-#{setup[:pretty_version]}" )
    package
  end

  def package_methods(package, setup)
    allow(package).to receive(:installation_source).and_return( setup.key?(:installation_source) ? setup[:installation_source] : nil )
    allow(package).to receive(:source_type).and_return( setup.key?(:source_type) ? setup[:source_type] : nil )
    allow(package).to receive(:source_url).and_return( setup.key?(:source_url) ? setup[:source_url] : nil )
    allow(package).to receive(:source_reference).and_return( setup.key?(:source_reference) ? setup[:source_reference] : nil )
    allow(package).to receive(:source_mirrors).and_return( setup.key?(:source_mirrors) ? setup[:source_mirrors] : nil )
    allow(package).to receive(:dist_type).and_return( setup.key?(:dist_type) ? setup[:dist_type] : nil )
    allow(package).to receive(:dist_url).and_return( setup.key?(:dist_url) ? setup[:dist_url] : nil )
    allow(package).to receive(:dist_reference).and_return( setup.key?(:dist_reference) ? setup[:dist_reference] : nil )
    allow(package).to receive(:dist_sha1_checksum).and_return( setup.key?(:dist_sha1_checksum) ? setup[:dist_sha1_checksum] : nil )
    allow(package).to receive(:dist_mirrors).and_return( setup.key?(:dist_mirrors) ? setup[:dist_mirrors] : nil )
    allow(package).to receive(:release_date).and_return( setup.key?(:release_date) ? setup[:release_date] : nil )
    allow(package).to receive(:extra).and_return( setup.key?(:extra) ? setup[:extra] : {} )
    allow(package).to receive(:binaries).and_return( setup.key?(:binaries) ? setup[:binaries] : [] )
    allow(package).to receive(:requires).and_return( setup.key?(:requires) ? setup[:requires] : {} )
    allow(package).to receive(:conflicts).and_return( setup.key?(:conflicts) ? setup[:conflicts] : {} )
    allow(package).to receive(:provides).and_return( setup.key?(:provides) ? setup[:provides] : {} )
    allow(package).to receive(:replaces).and_return( setup.key?(:replaces) ? setup[:replaces] : {} )
    allow(package).to receive(:dev_requires).and_return( setup.key?(:dev_requires) ? setup[:dev_requires] : {} )
    allow(package).to receive(:suggests).and_return( setup.key?(:suggests) ? setup[:suggests] : {} )
    allow(package).to receive(:autoload).and_return( setup.key?(:autoload) ? setup[:autoload] : {} )
    allow(package).to receive(:dev_autoload).and_return( setup.key?(:dev_autoload) ? setup[:dev_autoload] : {} )
    allow(package).to receive(:include_paths).and_return( setup.key?(:include_paths) ? setup[:include_paths] : [] )
    allow(package).to receive(:archive_excludes).and_return( setup.key?(:archive_excludes) ? setup[:archive_excludes] : [] )
    allow(package).to receive(:notification_url).and_return( setup.key?(:notification_url) ? setup[:notification_url] : nil )
    allow(package).to receive(:target_dir).and_return( setup.key?(:target_dir) ? setup[:target_dir] : nil )
    allow(package).to receive(:is_dev).and_return( setup.key?(:is_dev) ? setup[:is_dev] : false )
    package
  end

  def complete_package_methods(package, setup)
    allow(package).to receive(:scripts).and_return( setup.key?(:scripts) ? setup[:scripts] : [] )
    allow(package).to receive(:repositories).and_return( setup.key?(:repositories) ? setup[:repositories] : nil )
    allow(package).to receive(:license).and_return( setup.key?(:license) ? setup[:license] : [] )
    allow(package).to receive(:keywords).and_return( setup.key?(:keywords) ? setup[:keywords] : nil )
    allow(package).to receive(:authors).and_return( setup.key?(:authors) ? setup[:authors] : nil )
    allow(package).to receive(:description).and_return( setup.key?(:description) ? setup[:description] : nil )
    allow(package).to receive(:homepage).and_return( setup.key?(:homepage) ? setup[:homepage] : nil )
    allow(package).to receive(:support).and_return( setup.key?(:support) ? setup[:support] : [] )
    allow(package).to receive(:is_abandoned?).and_return( setup.key?(:abandoned) ? setup[:abandoned] : false )
    package
  end

  def root_package_methods(package, setup)
    allow(package).to receive(:minimum_stability).and_return( setup.key?(:minimum_stability) ? setup[:minimum_stability] : 'stable' )
    allow(package).to receive(:prefer_stable).and_return( setup.key?(:prefer_stable) ? setup[:prefer_stable] : nil )
    allow(package).to receive(:stability_flags).and_return( setup.key?(:stability_flags) ? setup[:stability_flags] : [] )
    allow(package).to receive(:references).and_return( setup.key?(:references) ? setup[:references] : [] )
    allow(package).to receive(:aliases).and_return( setup.key?(:aliases) ? setup[:aliases] : [] )
    package
  end
end
