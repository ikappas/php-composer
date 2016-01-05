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
      #
      # @param source string
      # @param target string
      # @param constraint LinkConstraintInterface Constraint applying to the target of this link
      # @param description string Used to create a descriptive string representation
      # @param pretty_constraint string
      def initialize(source, target, constraint = nil, description = 'relates to', pretty_constraint = nil)
        @source = source.downcase
        @target = target.downcase
        @constraint = constraint
        @description = description
        @pretty_constraint = pretty_constraint
      end

      # Get the link's pretty constraint.
      #
      # @return string
      def pretty_constraint
        unless @pretty_constraint
          raise UnexpectedValueError, "Link #{self} has been misconfigured and had no pretty constraint given."
        end
        @pretty_constraint
      end

      # Get the link's pretty string.
      #
      # @return string
      def pretty_string(source_package)
        "#{source_package.pretty_string} #{@description} #{@target} #{@constraint.pretty_string}"
      end

      # Get the link's string representation.
      #
      # @return string
      def to_s
        "#{@source} #{@description} #{@target} (#{@constraint})"
      end

    end
  end
end
