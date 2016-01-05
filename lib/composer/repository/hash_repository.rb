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

require 'composer/semver'

module Composer
  module Repository
    class HashRepository < ::Composer::Repository::BaseRepository

      def initialize(packages = [])
        packages.each {|p| add_package p } if packages.instance_of? Array
      end

      def find_package(name, version = nil)
        # normalize name
        name.downcase! unless name.nil?

        # normalize version
        unless version.nil?
          version_parser = ::Composer::Semver::VersionParser.new
          version = version_parser.normalize(version)
        end

        match = nil
        packages.each do |package|
          if package.name === name
            if version.nil? || package.version === version
              match = package
              break
            end
          end
        end
        match
      end

      def find_packages(name, version = nil)
        # normalize name
        name.downcase! unless name.nil?

        # normalize version
        unless version.nil?
          version_parser = ::Composer::Semver::VersionParser.new
          version = version_parser.normalize(version)
        end

        matches = []
        packages.each do |package|
          if package.name === name && (version.nil? || version === package.version)
            matches.push package
          end
        end
        matches
      end

      ##
      # Searches the repository for packages containing the query
      #
      # @param query string
      #   The search query
      # @param mode int
      #   A set of SEARCH_* constants to search on, implementations should do a best effort only
      #
      # @return array[] an array of array('name' => '...', 'description' => '...')
      ##
      def search(query, mode = 0)

        regex = /(?:#{query.split(/\s+/).join('|')})/i

        matches = {}
        packages.each do |package|

          name = package.name

          # skip if already matched
          next if matches[name]

          # search
          if regex.match(name) ||
              mode === ::Composer::Repository::BaseRepository::SEARCH_FULLTEXT &&
              package.kind_of?(::Composer::Package::CompletePackage) &&
              regex.match("#{package.keywords ? package.keywords.join(' ') : ''} #{package.description ? package.description : ''}")

            matches[name] = {
                'name' => package.pretty_name,
                'description' => package.send('description'),
            }
          end
        end
        matches.values
      end

      def package?(package)
        unless package
          raise ArgumentError,
                'package must be specified'
        end
        unless package.is_a?(::Composer::Package::Package)
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

      ##
      # Adds a new package to the repository
      #
      # @param package Composer::Package::Package
      #   The package to add
      ##
      def add_package(package)
        unless package
          raise ArgumentError,
                'package must be specified'
        end
        unless package.is_a?(::Composer::Package::Package)
          raise TypeError,
                'package must be a class or superclass of \
                Composer::Package::Package'
        end

        initialize_repository unless @packages

        package.repository = self

        @packages << package

        if package.instance_of?(::Composer::Package::AliasPackage)
          aliased_package = package.alias_of
          if aliased_package.repository === nil
            add_package(aliased_package)
          end
        end
      end

      ##
      # Removes package from repository.
      #
      # @param package Composer::Package::Package
      #   The package instance to remove
      ##
      def remove_package(package)
        unless package
          raise ArgumentError,
                'package must be specified'
        end
        unless package.is_a?(::Composer::Package::Package)
          raise TypeError,
                'package must be a class or superclass of \
                Composer::Package::Package'
        end

        package_id = package.unique_name

        index = 0
        packages.each do |repo_package|
          if repo_package.unique_name === package_id
            @packages.delete_at(index)
            break
          end
          index = index + 1
        end
      end

      def packages
        initialize_repository unless @packages
        @packages
      end

      def count
        packages.length
      end

      protected

      ##
      # Initializes the packages array.
      # Mostly meant as an extension point.
      ##
      def initialize_repository
        @packages = []
      end

      def create_alias_package(package, version, pretty_version)
        if package.instance_of?(::Composer::Package::AliasPackage)
          alias_of = package.alias_of
        else
          alias_of = package
        end
        ::Composer::Package::AliasPackage.new(
          alias_of,
          version,
          pretty_version
        )
      end

    end
  end
end
