#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Package\BasePackage.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package

    # Base class for packages providing name storage
    # and default match implementation
    # @php_author Nils Adermann <naderman@naderman.de>
    # @author Ioannis Kappas <ikappas@devworks.gr>
    class BasePackage

      # base package attributes
      attr_accessor :id, :repository, :transport_options
      attr_reader :name, :pretty_name, :version, :pretty_version, :stability

      STABILITY_STABLE  = 0
      STABILITY_RC      = 5
      STABILITY_BETA    = 10
      STABILITY_ALPHA   = 15
      STABILITY_DEV     = 20

      SUPPORTED_LINK_TYPES = {
        'require' => {
          'description' => 'requires',
          'method' => 'requires'
        },
        'conflict' => {
          'description' => 'conflicts',
          'method' => 'conflicts'
        },
        'provide' => {
          'description' => 'provides',
          'method' => 'provides'
        },
        'replace' => {
          'description' => 'replaces',
          'method' => 'replaces'
        },
        'require-dev' => {
          'description' => 'requires (for development)',
          'method' => 'dev_requires'
        }
      }.freeze()

      class << self

        def stabilities
          @stabilities ||= {
            'stable' => STABILITY_STABLE,
            'RC'     => STABILITY_RC,
            'beta'   => STABILITY_BETA,
            'alpha'  => STABILITY_ALPHA,
            'dev'    => STABILITY_DEV,
          }.freeze()
        end

      end

      # Creates a new in memory package.
      # Param: string name           The package's name
      # Param: string version        The package's version
      # Param: string pretty_version The package's non-normalized version
      def initialize(name)
        @pretty_name = name
        @name = name.downcase
        @id = -1
        @transport_options = []
      end

      def attributes
        dumper = Composer::Package::Dumper::HashDumper.new
        dumper.dump(self)
      end

      # Set package type
      # Param: string type
      def type=(type)
        @type = type
      end

      # Get package type
      # Return: string
      def type
        @type ? @type : 'library'
      end

      # Set package repository
      def repository=(repository)
        if (@repository && repository != @repository)
          raise LogicError, 'A package can only be added to one repository'
        end
        @repository = repository
      end

      # Get package repository
      def repository
        @repository
      end

      # def is_platform?
      #   @repository && @repository.instance_of?(PlatformRepository)
      # end

      # Returns package unique name, constructed from name, version and
      # release type.
      # Return: string
      def unique_name
        "#{name}-#{version}"
      end

      def pretty_string
        "#{pretty_name} #{pretty_version}"
      end

      def to_s
        unique_name
      end

    end
  end
end
