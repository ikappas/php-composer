#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Package\Package.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package

    # Core package definitions that are needed to resolve dependencies
    # and install packages
    class Package < Composer::Package::BasePackage

      attr_reader :stability

      attr_accessor :installation_source, :source_type,
                    :source_url, :source_reference, :source_mirrors, :dist_type,
                    :dist_url, :dist_reference, :dist_sha1_checksum,
                    :dist_mirrors, :release_date, :extra, :binaries, :requires,
                    :conflicts, :provides, :replaces, :dev_requires, :suggests,
                    :autoload, :dev_autoload, :include_paths, :archive_excludes,
                    :notification_url

      # complete package attributes


      # Creates a new in memory package.
      # Param: string name          The package's name
      # Param: string version       The package's version
      # Param: string prettyVersion The package's non-normalized version
      def initialize(name, version, pretty_version)
        super(name)

        # default values
        @extra = {}
        @binaries = []
        @requires = {}
        @conflicts = {}
        @provides = {}
        @replaces = {}
        @dev_requires = {}
        @suggests = {}
        @autoload = {}
        @dev_autoload = {}
        @include_paths = []
        @archive_excludes = []

        # init package attributes
        replace_version(version, pretty_version)

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

      def target_dir=(target_dir)
        @target_dir = target_dir
      end

      def target_dir
        return unless @target_dir
        regex = '(?:^|[\\\\/]+)\.\.?(?:[\\\\/]+|$)(?:\.\.?(?:[\\\\/]+|$))*'
        @target_dir.gsub(/#{regex}/x, '/').gsub(/^\/+/, '')
      end

      # Returns package unique name, constructed from name, version and
      # release type.
      # Return: string
      def unique_name
        "#{name}-#{version}"
      end

      def pretty_string
        "#{pretty_name} #{pretty_version}"
      end

      # Determine if development package
      # Return: true if development package; Otherwise false.
      def is_dev
        @dev
      end

      # Replaces current version and pretty version with passed values.
      # It also sets stability.
      # Param: string version       The package's normalized version
      # Param: string prettyVersion The package's non-normalized version
      def replace_version(version, pretty_version)
        @version = version
        @pretty_version = pretty_version

        @stability = Composer::Package::Version::VersionParser::parse_stability(version)
        @dev = @stability === 'dev'
      end

    end
  end
end
