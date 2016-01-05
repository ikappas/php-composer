#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Package\RootPackage.php
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
    # The root package represents the project's composer.json
    # and contains additional metadata
    ##
    class RootPackage < ::Composer::Package::CompletePackage

      attr_accessor :minimum_stability, :prefer_stable, :stability_flags,
                    :references, :aliases

      ##
      # Creates a new root package in memory package.
      #
      # @param name string name
      #   The package's name
      # @param version string version
      #   The package's version
      # @param: pretty_version string
      #   The package's non-normalized version
      ##
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
