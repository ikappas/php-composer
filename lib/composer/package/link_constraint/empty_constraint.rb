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
    module LinkConstraint
      class EmptyConstraint < BaseConstraint
        def matches(provider)
          true
        end

        def pretty_string=(pretty_string)
           @pretty_string = pretty_string
        end

        def pretty_string
          return to_s unless @pretty_string
          @pretty_string
        end

        def to_s
          '[]'
        end
      end
    end
  end
end