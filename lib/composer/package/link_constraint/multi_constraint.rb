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
      class MultiConstraint < BaseConstraint
         # Sets operator and version to compare a package with
         # @param array $constraints A set of constraints
         # @param bool  $conjunctive Whether the constraints should be treated as conjunctive or disjunctive
        def initialize(constraints, conjunctive = true)
          @constraints = constraints
          @conjunctive = conjunctive
        end

        def matches(provider)
          if @conjunctive === false
            @constraints.each do |constraint|
              if constraint.matches(provider)
                return true
              end
            end
            return false
          end

          @constraints.each do |constraint|
            if !constraint.matches(provider)
              return false
            end
          end

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
          constraints = []
          @constraints.each do |constraint|
            if constraint.is_a?(Array)
              constraints << String(constraint[0])
            else
              constraints << String(constraint)
            end
          end
          separator = @conjunctive ? ' ' : ' || '
          "[#{constraints.join(separator)}]"
        end
      end
    end
  end
end