#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Repository\CompositeRepository.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Repository
    # CompositeRepository repository.
    #
    # PHP Authors:
    # Beau Simensen <beau@dflydev.com>
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class CompositeRepository < Composer::Repository::BaseRepository
      # Initializes filesystem repository.
      # @param [Array] An array of reporitories
      def initialize(repositories)
        unless repositories
          raise ArgumentError,
                'repositories must be specified'
        end
        unless repositories.is_a?(Array)
          raise TypeError,
                'repositories type must be an \
                Array of Composer::Repository::BaseRepository'
        end
        @repositories = []
        repositories.each do |repository|
          add_repository(repository)
        end
      end

      def repositories
        @repositories
      end

      def package?(package)
        @repositories.each do |repo|
          if repo.package?(package)
            return true
          end
        end
        false
      end

      def find_package(name, version = nil)
        @repositories.each do |repo|
          package = repo.find_package(name, version)
          return package unless package.nil?
        end
      end

      def find_packages(name, version = nil)
        packages = []
        @repositories.each do |repo|
          if (repo_packages = repo.find_packages(name, version))
            packages.merge(repo_packages)
          end
        end
        packages
      end

      def search(query, mode = 0)
        matches = []
        @repositories.each do |repo|
          if (repo_matches = repo.search(query, mode))
            matches.merge(repo_matches)
          end
        end
        matches
      end

      def packages
        packages = []
        @repositories.each do |repo|
          if (repo_packages = repo.packages)
            packages.merge(repo_packages)
          end
        end
        packages
      end

      def count
        total = 0;
        @repositories.each do |repo|
          total += repo.count
        end
        total
      end

      def add_repository(repository)
        unless repository
          raise ArgumentError,
                'repository must be specified'
        end
        unless repository.instance_of?(Composer::Repository::RepositoryBase)
          raise TypeError,
                'repository type must be a \
                Composer::Repository::BaseRepository or superclass'
        end
        if repository.instance_of?(self)
          repository.repositories.each do |repo|
            add_repository(repo)
          end
        else
            @repositories.push(repository)
        end
      end
    end
  end
end
