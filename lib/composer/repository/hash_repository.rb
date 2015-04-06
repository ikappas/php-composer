#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Repository\ArrayRepository.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Repository
    class HashRepository
      def initialize(packages = [])
        packages.each do |package|
          add_package(package)
        end
      end

      def find_package(name, version = nil)
        # normalize name
        name = name.downcase

        # normalize version
        if version != nil
          version_parser = Composer::Package::Version::VersionParser.new
          version = version_parser.normalize(version)
        end

        packages.each do |package|
          if package.name === name && (nil === version || version === package.version)
            return package
          end
        end

      end

      def find_packages(name, version = nil)
          # normalize name
          name = name.downcase

          # normalize version
          if version != nil
            version_parser = Composer::Package::Version::VersionParser.new
            version = version_parser.normalize(version)
          end

          matches = []
          packages.each do |package|
            if package.name === name && (nil === version || version === package.version)
              matches << package
            end
          end
          matches
      end

      def search(query, full_search = false)
        regex = /(?:#{query.split(/\s+/).join('|')})/i
        matches = {}
        packages.each do |package|
          name = package.name

          # already matched
          next if matches['name']

          # search
          if full_search
            next unless (
              package.instance_of?(Composer::Package::CompletePackage) &&
              regex.match("#{package.keywords.join(' ')} #{package.description}")
            )
          else
            next unless (
              full_search == false &&
              regex.match(name)
            )
          end

          matches[name] = {
            'name' => package.pretty_name,
            'description' => package.description,
          }
        end
        matches
      end

      def package?(package)
        unless package
          raise ArgumentError,
                'package must be specified'
        end
        unless package.is_a?(Composer::Package::BasePackage)
          raise TypeError,
                'package must be a class or superclass of \
                Composer::Package::Package'
        end

        package_id = package.unique_name
        packages.each do |repo_package|
          return true if repo_package.unique_name === package_id
        end

        false
      end

      # Adds a new package to the repository
      #
      # Params:
      # +package+ Package The package to add
      def add_package(package)
        unless package
          raise ArgumentError,
                'package must be specified'
        end
        unless package.is_a?(Composer::Package::BasePackage)
          raise TypeError,
                'package must be a class or superclass of \
                Composer::Package::Package'
        end

        initialize_repository unless @packages

        package.repository = self

        @packages << package

        if package.instance_of?(Composer::Package::AliasPackage)
          aliased_package = package.alias_of
          if aliased_package.repository === nil
            add_package(aliased_package)
          end
        end
      end

      # Removes package from repository.
      #
      # Params:
      # +package+ package instance to remove
      def remove_package(package)
        unless package
          raise ArgumentError,
                'package must be specified'
        end
        unless package.is_a?(Composer::Package::BasePackage)
          raise TypeError,
                'package must be a class or superclass of \
                Composer::Package::Package'
        end

        package_id = package.unique_name

        index = 0
        packages.each do |repo_package|
          if repo_package.unique_name === package_id
            @packages.delete_at(index)
            return
          end
          index = index + 1
        end
      end

      def packages
        initialize_repository unless @packages
        @packages
      end

      def count
        @packages.length
      end

      protected

      # Initializes the packages array.
      # Mostly meant as an extension point.
      def initialize_repository
        @packages = []
      end

      def create_alias_package(package, version, pretty_version)
        if package.instance_of?(Composer::Package::AliasPackage)
          alias_of = package.alias_of
        else
          alias_of = package
        end
        Composer::Package::AliasPackage.new(
          alias_of,
          version,
          pretty_version
        )
      end

    end
  end
end
