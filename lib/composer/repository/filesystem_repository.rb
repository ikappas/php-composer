#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Repository\FilesystemRepository.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Repository
    # Filesystem repository.
    #
    # PHP Authors:
    # Konstantin Kudryashov <ever.zet@gmail.com>
    # Jordi Boggiano <j.boggiano@seld.be>
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class FilesystemRepository < Composer::Repository::WritableHashRepository

      # Initializes filesystem repository.
      # @param [Composer::Json::JsonFile] repository_file repository json file
      def initialize(repository_file)
        unless repository_file
          raise ArgumentError,
                'repository_file must be specified'
        end
        unless repository_file.is_a?(Composer::Json::JsonFile)
          raise TypeError,
                'repository_file type must be a \
                Composer::Json::JsonFile or superclass'
        end
        super([])
        @file = repository_file
      end


      def reload
        @packages = nil
        configure
      end

      # Writes writable repository.
      def write
        data = []
        dumper = Composer::Package::Dumper::HashDumper.new

        canonical_packages.each { |package| data << dumper.dump(package) }

        @file.write(data)
      end

      protected

      # Initializes repository (reads file, or remote address).
      def initialize_repository
        super
        return unless @file.exists?

        begin
          packages_data = @file.read
          unless packages_data.is_a?(Array)
            raise UnexpectedValueError,
                  'Could not parse package list from the repository'
          end
        rescue Exception => e
          raise InvalidRepositoryError,
                "Invalid repository data in #{@file.path}, \
                packages could not be loaded: \
                [#{e.class}] #{e.message}"
        end

        loader = Composer::Package::Loader::HashLoader.new(nil, true)
        packages_data.each do |package_data|
          package = loader.load(package_data)
          add_package(package)
        end

      end

    end
  end
end