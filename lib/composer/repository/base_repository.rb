#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Repository\RepositoryInterface.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Repository
    # Base repository.
    #
    # PHP Authors:
    # Nils Adermann <naderman@naderman.de>
    # Konstantin Kudryashov <ever.zet@gmail.com>
    # Jordi Boggiano <j.boggiano@seld.
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class BaseRepository
      SEARCH_FULLTEXT = 0
      SEARCH_NAME = 1

      ##
      # Determine whether the specified package is registered (installed).
      #
      # @param package ::Composer::Package::Package
      #  The package to check for.
      # @return bool
      #  True if the package is registered; Otherwise false.
      #
      def package?(package)
        # implement inside child
      end

      ##
      # Searches for the first match of a package by name and version.
      #
      # @param name string
      #   The package name.
      # @param constraint string|::Composer::Semver::Constraint::Constraint
      #   The package version or version constraint to match against
      #
      # @return PackageInterface|nil
      #
      def find_package(name, constraint)
        # implement inside child
      end

      ##
      # Searches for all packages matching a name and optionally a version.
      #
      # @param name string
      #   The package name.
      # @param constraint string|::Composer::Semver::Constraint::Constraint
      #   Optional. The package version or version constraint to match against.
      #
      # @return ::Composer::Package::Package[]
      ##
      def find_packages(name, constraint = nil)
        # implement inside child
      end

      ##
      # Returns list of registered packages.
      #
      # @return ::Composer::Package::Package[]
      ##
      def packages
        # implement inside child
      end

      ##
      # Searches the repository for packages containing the query
      #
      # @param query string
      #   The search query
      # @param mode integer
      #   A set of SEARCH_* constants to search on, implementations should do a best effort only.
      #
      # @return hash[] an array of hash { 'name' => '...', 'description' => '...')
      #
      def search(query, mode = 0)
        # implement inside child
      end
    end
  end
end
