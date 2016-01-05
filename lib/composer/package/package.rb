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

require 'composer/semver'

module Composer
  module Package

    SUPPORTED_LINK_TYPES = {
        'require' => {
            description: 'requires',
            method: 'requires'
        },
        'conflict' => {
            description: 'conflicts',
            method: 'conflicts'
        },
        'provide' => {
            description: 'provides',
            method: 'provides'
        },
        'replace' => {
            description: 'replaces',
            method: 'replaces'
        },
        'require-dev' => {
            description: 'requires (for development)',
            method: 'dev_requires'
        }
    }.freeze

    STABILITY_STABLE  = 0
    STABILITY_RC      = 5
    STABILITY_BETA    = 10
    STABILITY_ALPHA   = 15
    STABILITY_DEV     = 20

    STABILITIES = {
      'stable' => STABILITY_STABLE,
      'RC'     => STABILITY_RC,
      'beta'   => STABILITY_BETA,
      'alpha'  => STABILITY_ALPHA,
      'dev'    => STABILITY_DEV,
    }.freeze()

    ##
    # Core package definitions that are needed to resolve dependencies
    # and install packages
    ##
    class Package

      ##
      # Creates a new in memory package.
      #
      # @param name string
      #   The package's name
      # @param version string
      #   The package's version
      # @param: pretty_version string
      #   The package's non-normalized version
      ##
      def initialize(name, version, pretty_version)

        @pretty_name = name
        @name = name.downcase
        @id = -1
        @transport_options = []
        @repository = nil
        @type = nil

        # default values
        @type = nil
        @target_dir = nil
        @installation_source = nil
        @source_type = nil
        @source_url = nil
        @source_reference = nil
        @source_mirrors = nil
        @dist_type = nil
        @dist_url = nil
        @dist_reference = nil
        @dist_sha1_checksum = nil
        @dist_mirrors = nil
        @version = nil
        @pretty_version = nil
        @release_date = nil
        @extra = {}
        @binaries = []
        @dev = nil
        @stability = nil
        @notification_url = nil

        # @var Hash of package name => Link
        @requires = {}
        # @var Hash of package name => Link
        @conflicts = {}
        # @var Hash of package name => Link
        @provides = {}
        # @var Hash of package name => Link
        @replaces = {}
        # @var Hash of package name => Link
        @dev_requires = {}

        @suggests = {}
        @autoload = {}
        @dev_autoload = {}
        @include_paths = []
        @archive_excludes = []

        # init package attributes
        replace_version(version, pretty_version)

      end

      ##
      # Returns whether the package is a development virtual package or a concrete one
      # @return bool
      ##
      def is_dev?
        @dev
      end

      ##
      # Allows the solver to set an id for this package to refer to it.
      #
      # @param id integer
      ##
      attr_writer :id

      ##
      # Retrieves the package's id
      #
      # @return int The previously set package id
      ##
      attr_reader :id

      ##
      # Get the package name
      #
      # @return string
      ##
      attr_reader :name

      ##
      # Get the package pretty name
      #
      # @return string
      ##
      attr_reader :pretty_name

      ##
      # Returns a set of names that could refer to this package
      #
      # No version or release type information should be included in any of the
      # names. Provided or replaced package names need to be returned as well.
      #
      # @return array An array of strings referring to this package
      ##
      def names
        names = {}

        names[name] = true

        provides.each do |link|
          names[link.target] = true
        end

        replaces.each do |link|
          names[link.target] = true
        end

        names.keys
      end


      ##
      # Set the package type.
      # @param type string
      ##
      attr_writer :type

      ##
      # Get package type.
      # @return string
      def type
        @type ? @type : 'library'
      end

      ##
      # Get the package stability.
      #
      # @return string|nil
      ##
      attr_reader :stability

      ##
      # Get the package stability priority.
      ##
      def stability_priority
        ::Composer::Package::STABILITIES[stability]
      end

      ##
      # Set the target directory
      # @param target_dir string
      ##
      attr_writer :target_dir

      ##
      # Get target directory
      # @return string| nil
      #
      def target_dir
        return if @target_dir.nil?
        regex = '(?:^|[\\\\/]+)\.\.?(?:[\\\\/]+|$)(?:\.\.?(?:[\\\\/]+|$))*'
        @target_dir.gsub(/#{regex}/x, '/').gsub(/^\/+/, '')
      end

      ##
      # Set the package extra
      # @param extra Hash
      ##
      attr_writer :extra

      ##
      # Get the package extra
      # @return Hash
      ##
      attr_reader :extra

      ##
      # Set the package binaries
      # @param binaries Array
      ##
      attr_writer :binaries

      ##
      # Get the package binaries
      # @return Hash|nil
      ##
      attr_reader :binaries

      ##
      # Set the package installation source
      # @param installation_source string
      ##
      attr_writer :installation_source

      ##
      # Get the package installation source
      # @return string|nil
      ##
      attr_reader :installation_source

      ##
      # Set the package source type
      # @param source_type string
      ##
      attr_writer :source_type

      ##
      # Get the package source type
      # @return string|nil
      ##
      attr_reader :source_type

      ##
      # Set the package source url
      # @param source_url string
      ##
      attr_writer :source_url

      ##
      # Get the package source url
      # @return string|nil
      ##
      attr_reader :source_url

      ##
      # Set the package source reference
      # @param source_reference string
      ##
      attr_writer :source_reference

      ##
      # Get the package source reference
      # @return string|nil
      ##
      attr_reader :source_reference

      # Get/Set the package source mirrors
      # @param source_mirrors array|nil
      ##
      attr_writer :source_mirrors

      ##
      # Get the package source mirrors
      # @return string|nil
      ##
      attr_reader :source_mirrors

      ##
      # Get the package source urls
      # @return array
      ##
      def source_urls
        get_urls( source_url, source_mirrors, source_reference, source_type, 'source')
      end

      ##
      # Set the package distribution type
      # @param dist_type string
      ##
      attr_writer :dist_type

      ##
      # Get the package distribution type
      # @return string|nil
      ##
      attr_reader :dist_type

      ##
      # Set the package distribution url
      # @param dist_url string
      ##
      attr_writer :dist_url

      ##
      # Get the package distribution url
      # @return string|nil
      ##
      attr_reader :dist_url

      ##
      # Set the package distribution reference
      # @param dist_reference string
      ##
      attr_writer :dist_reference

      ##
      # Get the package distribution reference
      # @return string|nil
      ##
      attr_reader :dist_reference

      ##
      # Set the package distribution sha1 checksum
      # @param dist_sha1_checksum string
      ##
      attr_writer :dist_sha1_checksum

      ##
      # Get the package distribution sha1 checksum
      # @return string|nil
      ##
      attr_reader :dist_sha1_checksum

      ##
      # Set the package distribution mirrors
      # @param dist_mirrors string
      ##
      attr_writer :dist_mirrors

      ##
      # Get the package distribution mirrors
      # @return string|nil
      ##
      attr_reader :dist_mirrors

      ##
      # Get the package distribution urls
      # @return array
      ##
      def dist_urls
        get_urls( dist_url, dist_mirrors, dist_reference, dist_type, 'dist' )
      end

      ##
      # Get the package version
      # @return string
      ##
      attr_reader :version

      ##
      # Get the package pretty version
      # @return string
      ##
      attr_reader :pretty_version

      ##
      # Returns the pretty version string plus a git or hg commit hash of this package
      #
      # @see pretty_version
      #
      # @param truncate bool
      #   If the source reference is a sha1 hash, truncate it
      #
      # @return string
      ##
      def full_pretty_version(truncate = true)
        unless is_dev? || %w{hg git}.include?(source_type)
          return pretty_version
        end

        # if source reference is a sha1 hash -- truncate
        if truncate && source_reference.length === 40
          return "#{pretty_version} #{source_reference[0..6]}"
        end

        "#{pretty_version} #{source_reference}"
      end

      ##
      # Replaces current version and pretty version with passed values.
      # It also sets stability.
      #
      # @param version string version
      #   The package's normalized version
      # @param pretty_version string
      #   The package's non-normalized version
      ##
      def replace_version(version, pretty_version)
        @version = version
        @pretty_version = pretty_version

        @stability = ::Composer::Semver::VersionParser::parse_stability(version)
        @dev = @stability === 'dev'
      end

      ##
      # Set the package release date
      # @param release_date Date
      ##
      attr_writer :release_date

      ##
      # Get the package release date
      # @return Date|nil
      ##
      attr_reader :release_date

      ##
      # Set the package requires
      # @param requires Hash of package name => Link
      ##
      attr_writer :requires

      ##
      # Get the package requires
      # @return Hash of package name => Link
      ##
      attr_reader :requires

      ##
      # Set the package conflicts
      # @param conflicts Hash of package name => Link
      ##
      attr_writer :conflicts

      ##
      # Get the package conflicts
      # @return Hash of package name => Link
      ##
      attr_reader :conflicts

      ##
      # Set the package provides
      # @param provides Hash of package name => Link
      ##
      attr_writer :provides

      ##
      # Get the package provides
      # @return Hash of package name => Link
      ##
      attr_reader :provides

      ##
      # Set the package replaces
      # @param replaces Hash of package name => Link
      ##
      attr_writer :replaces

      ##
      # Get the package replaces
      # @return Hash of package name => Link
      ##
      attr_reader :replaces

      ##
      # Set the package dev requires
      # @param dev_requires Hash of package name => Link
      ##
      attr_writer :dev_requires

      ##
      # Get the package dev requires
      # @return Hash of package name => Link
      ##
      attr_reader :dev_requires

      ##
      # Set the package suggests
      # @param suggests Hash of package name => comments
      ##
      attr_writer :suggests

      ##
      # Get the package suggests
      # @return Hash of package name => Link
      ##
      attr_reader :suggests

      ##
      # Set the package autoload mapping
      # @param autoload Hash Mapping of auto-loading rules
      ##
      attr_writer :autoload

      ##
      # Get the package autoload mapping
      # TODO: This conflicts with kernel method autoload
      # @return Array
      ##
      attr_reader :autoload

      ##
      # Set the package dev autoload mapping
      # @param dev_autoload Array Mapping of dev auto-loading rules
      ##
      attr_writer :dev_autoload

      ##
      # Get the package dev autoload mapping
      # @return Array
      ##
      attr_reader :dev_autoload

      ##
      # Set the list of paths added to PHP's include path.
      # @param include_paths Array List of directories
      ##
      attr_writer :include_paths

      ##
      # Get the package include_paths mapping
      # @return Array
      ##
      attr_reader :include_paths

      ##
      # Set the package notification url
      # @param notification_url string
      ##
      attr_writer :notification_url

      ##
      # Get the package notification url
      # @return string|nil
      ##
      attr_reader :notification_url

      # Set a list of patterns to be excluded from archives
      # @param archive_excludes Array
      ##
      attr_writer :archive_excludes

      ##
      # Get the package archive_excludes mapping
      # @return Array
      ##
      attr_reader :archive_excludes

      ##
      # Set the list of options to download package dist files
      # @param transport_options array
      ##
      attr_writer :transport_options

      ##
      # Returns a list of options to download package dist files
      # @return array
      ##
      attr_reader :transport_options

      ##
      # Stores a reference to the repository that owns the package
      # @param repository ::Composer::Repository::Repository
      ##
      def repository=(repository)
        unless @repository.nil? || @repository.equal?(repository)
          raise LogicError,
                'A package can only be added to one repository'
        end
        @repository = repository
      end

      ##
      # Returns a reference to the repository that owns the package
      # @return RepositoryInterface
      ##
      attr_reader :repository

      ##
      # Returns package unique name, constructed from name and version.
      # @return string
      ##
      def unique_name
        "#{name}-#{version}"
      end

      ##
      # Converts the package into a readable and unique string
      # @return string
      ##
      def to_s
        unique_name
      end

      ##
      # Converts the package into a pretty readable string
      # @return string
      ##
      def pretty_string
        "#{pretty_name} #{pretty_version}"
      end

      def is_platform?
        # repository.instance_of?(PlatformRepository)
        false
      end

      ##
      # Determine whether the specified package is equal to this package.
      # @param package
      ##
      def equal?(package)
        target = self
        if self.kind_of? ::Composer::Package::AliasPackage
          target = alias_of
        end
        if package.kind_of? ::Composer::Package::AliasPackage
          package = package.alias_of
        end
        package === target
      end

      protected

      ##
      # Helper method to combine urls by type
      ##
      def get_urls(url, mirrors, ref, type, url_type)
        return [] if url.nil?
        urls = [ url ]
        if mirrors
          mirrors.each do |mirror|
            if url_type === 'dist'
              mirror_url = ::Composer::Util::ComposerMirror::process_url(mirror['url'], name, version, ref, type)
            elsif url_type === 'source' && type === 'git'
              mirror_url = ::Composer::Util::ComposerMirror::process_git_url(mirror['url'], name, url, type)
            elsif url_type === 'source' && type === 'hg'
              mirror_url = ::Composer::Util::ComposerMirror::process_hg_url(mirror['url'], name, url, type)
            end
            unless urls.include? mirror_url
              func = mirror['preferred'] ? 'unshift' : 'push'
              urls.send(func, mirror_url)
            end
          end
        end
        urls
      end

    end
  end
end
