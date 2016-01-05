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
    class CompositeRepository < ::Composer::Repository::BaseRepository
      # Initializes filesystem repository.
      # @param [Array] repositories An array of repositories.
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
        package = nil
        @repositories.each do |repo|
          package = repo.find_package(name, version)
          break unless package.nil?
        end
        package
      end

      def find_packages(name, version = nil)
        packages = []
        @repositories.each do |repo|
          repo_packages = repo.find_packages(name, version)
          repo_packages.map { |p| packages.push(p) } unless repo_packages.empty?
        end
        packages
      end

      def search(query, mode = 0)
        matches = []
        @repositories.each do |repo|
          repo_matches = repo.search(query, mode)
          repo_matches.map{ |m| matches.push(m) } unless repo_matches.empty?
        end
        matches
      end

      # def filter_packages(callback, class_name = 'Composer::Package::Package')
      #   @repositories.each do |repo|
      #     if (false === repo.filter_packages(callback, class_name))
      #       return false
      #     end
      #   end
      #   true
      # end

      def packages
        packages = []
        @repositories.each do |repo|
          repo_packages = repo.packages
          repo_packages.map { |p| packages.push(p) } unless repo_packages.empty?
        end
        packages
      end

      def remove_package(package)
        @repositories.each do |repo|
          repo.remove_package(package)
        end
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
        unless repository.is_a?(::Composer::Repository::BaseRepository)
          raise TypeError,
                'repository type must be a \
                Composer::Repository::BaseRepository or superclass'
        end
        if repository.instance_of?(::Composer::Repository::CompositeRepository)
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
