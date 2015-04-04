#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Package\CompletePackage.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package

    # Package containing additional metadata that is not used by the solver
    class CompletePackage < Composer::Package::Package

      attr_accessor :scripts, :repositories, :license, :keywords, :authors,
                    :description, :homepage, :support

      # Creates a new in memory package.
      # Param: string name          The package's name
      # Param: string version       The package's version
      # Param: string prettyVersion The package's non-normalized version
      def initialize(name, version, pretty_version)
        super(name, version, pretty_version)

        @license = []
        @scripts = []
        @support = []
        @abandoned = false
      end

      # Determine if package is abandoned
      # Return: true if package is abandoned; Otherwise false.
      def is_abandoned?
        @abandoned
      end

      # Set abandoned
      # Param boolean|string $abandoned
      def abandoned=(abandoned)
        @abandoned = abandoned
      end

      # If the package is abandoned and has a suggested replacement,
      # this method returns it
      # @return string|nil
      def replacement_package
        return @abandoned.kind_of?(String) ? @abandoned : nil
      end

    end
  end
end
