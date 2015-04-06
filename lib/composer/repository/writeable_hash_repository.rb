#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Repository\WritableArrayRepository.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Repository
    # Writable array repository.
    #
    # PHP Authors:
    # Jordi Boggiano <j.boggiano@seld.be>
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class WritableHashRepository < Composer::Repository::HashRepository

      def initialize(packages = [])
        super
      end

      def write
      end

      def reload
      end

      def canonical_packages
        packages_uncanonicalized = packages

        # get at most one package of each name, preferring non-aliased ones
        packages_by_name = {}
        packages_uncanonicalized.each do |package|
          if !packages_by_name.key?(package.name) ||
            packages_by_name[package.name].instance_of?(Composer::Package::AliasPackage)
            packages_by_name[package.name] = package
          end
        end

        # unfold aliased packages
        results = []
        packages_by_name.each do |name, package|
          while package.instance_of?(Composer::Package::AliasPackage)
            package = package.alias_of
          end
          results.push(package)
        end

        results
      end
    end
  end
end