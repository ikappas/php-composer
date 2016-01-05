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

    # Represents a package containing additional metadata that is not used by the solver.
    class CompletePackage < ::Composer::Package::Package

      # Creates a new in memory complete package.
      #
      # Params:
      # +name+:: The package's name.
      # +version+:: The package's version.
      # +pretty_version+:: The package's non-normalized version.
      def initialize(name, version, pretty_version)
        super(name, version, pretty_version)
        @scripts = []
        @repositories = nil
        @license = []
        @keywords = nil
        @authors = nil
        @description = nil
        @homepage = nil
        @support = []
        @abandoned = false
      end

      attr_writer :scripts

      # Returns the scripts of this package
      # @return array array('script name' => array('listeners'))
      attr_reader :scripts

      # Set the repositories
      # @param repositories array
      attr_writer :repositories

      # Returns an array of repositories
      #
      # {"<type>": {<config key/values>}}
      #
      # @return array Repositories
      attr_reader :repositories

      # Set the license
      # @param license array
      attr_writer :license

      # Returns the package license, e.g. MIT, BSD, GPL
      # @return array The package licenses
      attr_reader :license

      # Set the keywords
      # @param keywords array
      attr_writer :keywords

      # Returns an array of keywords relating to the package
      # @return array
      attr_reader :keywords

      # Set the authors
      # @param authors array
      attr_writer :authors

      # Returns an array of authors of the package
      # Each item can contain name/homepage/email keys
      #
      # @return array
      attr_reader :authors

      # Set the description
      # @param description string
      attr_writer :description

      # Returns the package description
      # @return string
      attr_reader :description

      # Set the homepage
      # @param homepage string
      attr_writer :homepage

      # Returns the package homepage
      # @return string
      attr_reader :homepage

      # Set the support information
      # @param support array
      attr_writer :support

      # Returns the support information
      # @return array
      attr_reader :support

      # Determine whether the package is abandoned.
      # @return bool true if package is abandoned; Otherwise false.
      def abandoned?
        @abandoned.kind_of?(String) ? true : @abandoned === true
      end

      # Set abandoned
      # @param abandoned bool
      def abandoned=(abandoned)
        @abandoned = abandoned
      end

      # If the package is abandoned and has a suggested replacement,
      # this method returns it.
      # @return string|nil
      def replacement_package
        @abandoned.kind_of?(String) ? @abandoned : nil
      end

    end
  end
end
