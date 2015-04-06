#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Package\AliasPackage.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package

    # The root package represents the project's composer.json
    # and contains additional metadata
    # @php_author Jordi Boggiano <j.boggiano@seld.be>
    # @author Ioannis Kappas <ikappas@devworks.gr>
    class AliasPackage < Composer::Package::BasePackage

      attr_reader :alias_of, :requires, :conflicts, :provides, :replaces
                  :dev_requires

      attr_accessor :repositories, :license, :keywords, :authors,
                    :description, :homepage, :scripts, :support,
                    :source_url, :source_reference, :source_mirrors

      # All descendants' constructors should call this parent constructor
      # @param alias_of Package The package this package is an alias of
      # @param version String The version the alias must report
      # @param pretty_version String The alias's non-normalized version
      def initialize(alias_of, version, pretty_version)
        super(alias_of.name)

        @version = version
        @pretty_version = pretty_version
        @alias_of = alias_of
        @stability = Composer::Package::Version::VersionParser::parse_stability(version)
        @dev = @stability === 'dev'

        # replace self.version dependencies
        %w{requires dev_requires}.each do |type|

          links = alias_of.send(type)
          links.each do |index, link|
            # link is self.version, but must be replacing also the replaced version
            if 'self.version' === link.pretty_constraint
              links[index] = Composer::Package::Link.new(
                link.source,
                link.target,
                Composer::Package::LinkConstraint::VersionConstraint.new(
                  '=',
                  @version
                ),
                type,
                pretty_version
              )
            end
          end
          @type = links
        end

        # duplicate self.version provides
        %w{conflicts provides replaces}.each do |type|
          links = alias_of.send(type)
          new_links = []
          links.each do |link|
            # link is self.version, but must be replacing also the replaced version
            if 'self.version' === link.pretty_constraint
              new_links = Composer.Package.Link.new(
                link.source,
                link.target,
                Composer::Package::LinkConstraint.VersionConstraint.new(
                  '=',
                  @version
                ),
                type,
                pretty_version
              )
            end
          end
          @type = links.zip(new_links).flatten.compact
          # @type = (links << new_links)
        end

      end

      # Determine if development package
      # Return: true if development package; Otherwise false.
      def is_dev
        @dev
      end

      # Stores whether this is an alias created by an aliasing in the requirements of the root package or not
      # Use by the policy for sorting manually aliased packages first, see #576
      # @param bool $value
      # @return mixed
      def root_package_alias=(value)
        @root_package_alias = value
      end

      # @see setRootPackageAlias
      # @return bool
      def is_root_package_alias
        @root_package_alias
      end

      #######################################
      # Wrappers around the aliased package #
      #######################################

      def type
        @alias_of.Type
      end

      def target_dir
        @alias_of.target_dir
      end

      def extra
        @alias_of.extra
      end

      def installation_source=(type)
        @alias_of.installation_source = type
      end

      def installation_source
        @alias_of.installation_source
      end

      def source_type
        @alias_of.source_type
      end

      def source_url
        @alias_of.source_url
      end

      def source_urls
        @alias_of.source_urls
      end

      def source_reference=(reference)
        @alias_of.source_reference = reference
      end

      def source_reference
        @alias_of.source_reference
      end

      def source_mirrors=(mirrors)
        @alias_of.source_mirrors = mirrors
      end

      def source_mirrors
        @alias_of.SourceMirrors
      end

      def dist_type
        @alias_of.dist_type
      end

      def dist_url
        @alias_of.dist_url
      end

      def dist_urls
        @alias_of.dist_urls
      end

      def dist_reference
        @alias_of.dist_reference
      end

      def dist_reference=(reference)
        @alias_of.dist_reference = reference
      end

      def dist_sha1_checksum
        @alias_of.dist_sha1_checksum
      end

      def transport_options=(options)
        @alias_of.transport_options = options
      end

      def transport_options
        @alias_of.transport_options
      end

      def dist_mirrors=(mirrors)
        @alias_of.dist_mirrors = mirrors
      end

      def dist_mirrors
        @alias_of.dist_mirrors
      end

      def scripts
        @alias_of.scripts
      end

      def license
        @alias_of.license
      end

      def autoload
        @alias_of.autoload
      end

      def dev_autoload
        @alias_of.dev_autoload
      end

      def include_paths
        @alias_of.include_paths
      end

      def repositories
        @alias_of.repositories
      end

      def release_date
        @alias_of.release_date
      end

      def binaries
        @alias_of.binaries
      end

      def keywords
        @alias_of.keywords
      end

      def description
        @alias_of.description
      end

      def homepage
        @alias_of.homepage
      end

      def suggests
        @alias_of.suggests
      end

      def authors
        @alias_of.authors
      end

      def support
        @alias_of.support
      end

      def notification_url
        @alias_of.notification_url
      end

      def archive_excludes
        @alias_of.archive_excludes
      end

      def is_abandoned?
        @alias_of.is_abandoned?
      end

      def replacement_package
        @alias_of.replacement_package
      end
    end
  end
end
