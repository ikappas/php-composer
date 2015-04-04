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

    # The root package represents the project's composer.json
    # and contains additional metadata
    class RootAliasPackage < Composer::Package::CompletePackage

      attr_accessor :minimum_stability, :prefer_stable, :stability_flags,
                    :references, :aliases

      # Creates a new root package in memory package.
      # Param: string name          The package's name
      # Param: string version       The package's version
      # Param: string prettyVersion The package's non-normalized version
      def initialize(name, version, pretty_version)
        super(name, version, pretty_version)

        @minimum_stability = 'stable'
        @stability_flags = []
        @references = []
        @aliases = []
      end

    end
  end
end
