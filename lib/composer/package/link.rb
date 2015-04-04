#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Package\Link.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package

    # Represents a link between two packages, represented by their names
    class Link

      attr_reader :source, :target, :constraint

      # Creates a new package link.
      # @param string                  source
      # @param string                  target
      # @param LinkConstraintInterface constraint       Constraint applying to the target of this link
      # @param string                  description      Used to create a descriptive string representation
      # @param string                  prettyConstraint
      def initialize(source, target, constraint = nil, description = 'relates to', pretty_constraint = nil)
        @source = source.downcase
        @target = target.downcase
        @constraint = constraint
        @description = description
        @pretty_constraint = pretty_constraint
      end

      def pretty_constraint
        unless @pretty_constraint
          raise UnexpectedValueError, "Link #{self} has been misconfigured and had no pretty constraint given."
        end
        @pretty_constraint
      end

      def pretty_string(source_package)
        "#{source_package.pretty_string} #{@description} #{@target} #{@constraint.pretty_string}"
      end

      def to_s
        "#{@source} #{@description} #{@target} (#{@constraint})"
      end

    end
  end
end
