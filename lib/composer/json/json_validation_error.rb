#
# This file was ported to ruby from Composer php source code file.
#
# Original Source: Composer\Json\JsonValidationException.php
# Ref SHA: 16578d1d01656ce7b694abd5517af44395cc53b3
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Json

    # Represents a Json Validation error
    #
    # PHP Authors:
    # Jordi Boggiano <j.boggiano@seld.be>
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class JsonValidationError < ::Composer::Error
      attr_reader :errors

      def initialize(errors)
        @errors = errors
      end
    end

  end
end
