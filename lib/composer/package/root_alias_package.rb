#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Package\RootAliasPackage.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package

    ##
    # The root alias package represents the project's composer.json
    # and contains additional metadata.
    ##
    class RootAliasPackage < ::Composer::Package::AliasPackage

      ##
      # Creates a new root alias package.
      #
      # Params:
      # @param alias_of ::Composer::Package::Package
      #   The package this package is an alias of.
      # @param version string
      #   The version the alias must report.
      # @param pretty_version string
      #   The alias's non-normalized version.
      ##
      def initialize(alias_of, version, pretty_version)
        unless ::Composer::Package::ROOT_PACKAGE_INTERFACE.all? { |m| alias_of.respond_to?(m) }
          raise ArgumentError,
                %q("alias_of" must implement all methods defined in ROOT_PACKAGE_INTERFACE)
        end
        super(alias_of, version, pretty_version)
      end

      ##
      # Returns a set of package names and their aliases.
      # @return array
      ##
      def aliases
        alias_of.aliases
      end

      ##
      # Returns the minimum stability of the package.
      # @return string
      ##
      def minimum_stability
        alias_of.minimum_stability
      end

      ##
      # Returns the stability flags to apply to dependencies.
      #
      # array('foo/bar' => 'dev')
      #
      # @return array
      ##
      def stability_flags
        alias_of.stability_flags
      end

      ##
      # Returns a set of package names and source references that must be enforced on them.
      #
      # array('foo/bar' => 'abcd1234')
      #
      # @return array
      ##
      def references
        alias_of.references
      end

      ##
      # Returns true if the root package prefers picking stable packages over unstable ones.
      # @return bool
      ##
      def prefer_stable?
        alias_of.prefer_stable?
      end

      ##
      # Set the required packages.
      #
      # @param requires array
      #   A set of package links.
      ##
      def requires=(requires)
        @requires = replace_self_version_dependencies(requires, 'requires')
        alias_of.requires = requires
      end

      ##
      # Set the recommended packages.
      #
      # @param dev_requires array
      #   A set of package links.
      ##
      def dev_requires=(dev_requires)
        @dev_requires = replace_self_version_dependencies(dev_requires, 'devRequires')
        alias_of.dev_requires = dev_requires
      end

      ##
      # Set the conflicting packages.
      #
      # @param conflicts array
      #   A set of package links.
      ##
      def conflicts=(conflicts)
        @conflicts = replace_self_version_dependencies(conflicts, 'conflicts')
        alias_of.conflicts = conflicts
      end

      ##
      # Set the provided virtual packages.
      #
      # @param provides array
      #   A set of package links.
      ##
      def provides=(provides)
        @provides = replace_self_version_dependencies(provides, 'provides')
        alias_of.provides = provides
      end

      ##
      # Set the packages this one replaces.
      #
      # @param replaces array
      #   A set of package links.
      ##
      def replaces=(replaces)
        @replaces = replace_self_version_dependencies(replaces, 'replaces')
        alias_of.replaces = replaces
      end

      ##
      # Set the repositories.
      #
      # @param repositories array
      #   A set of package links.
      ##
      def repositories=(repositories)
        alias_of.repositories = repositories
      end

      ##
      # Set the autoload mapping.
      #
      # @param autoload array
      #   An array of autoloaded packages.
      ##
      def autoload=(autoload)
        alias_of.autoload(autoload);
      end

      ##
      # Set the dev autoload mapping.
      #
      # @param dev_autoload array
      #   An array of dev autoloaded packages.
      ##
      def dev_autoload=(dev_autoload)
        alias_of.dev_autoload(dev_autoload)
      end

      ##
      # Set the stability flags.
      #
      # @param stability_flags array
      #   An array of stability flags.
      ##
      def stability_flags=(stability_flags)
        alias_of.stability_flags(stability_flags)
      end

      ##
      # Set the package suggested packages.
      #
      # @param suggests array
      #   An array of suggested packages.
      ##
      def suggests=(suggests)
        alias_of.suggests(suggests)
      end

      ##
      # Set the package extra packages.
      #
      # @param extra array
      #   An array of extra packages.
      ##
      def extra=(extra)
        alias_of.extra(extra)
      end

      # def __clone
      #     parent::__clone;
      # this->aliasOf = clone this->aliasOf;
      # end

    end
  end
end
