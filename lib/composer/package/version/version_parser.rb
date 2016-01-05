##
# This file was ported to ruby from Composer php source code file.
#
# Original Source: Composer\Package\Version\VersionParser.php
# Ref SHA: 1328d9c3b2fbe2d71079c5009b2d5204ce956c2e
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
##

require 'composer/semver'

module Composer
  module Package
    module Version

      ##
      # Version Parser
      #
      # PHP Authors:
      # Jordi Boggiano <j.boggiano@seld.be>
      #
      # Ruby Authors:
      # Ioannis Kappas <ikappas@devworks.gr>
      ##
      class VersionParser < ::Composer::Semver::VersionParser

        ##
        # Parses a name/version pairs and returns an array of pairs + the
        #
        # Params:
        # @param pairs
        #   a set of package/version pairs separated by ":", "=" or " "
        #
        # @return array[]
        #   An array of arrays containing a name and (if provided) a version
        ##
        def parse_name_version_pairs(pairs)
          pairs = pairs.values
          result = []

          for i in 0..(pairs.length - 1)
            pair = pairs[i].strip!.gsub(/^([^=: ]+)[=: ](.*)$/, '$1 $2')
            if nil === pair.index(' ') && pairs.key?(i + 1) && nil === pairs[i + 1].index('/')
              pair = "#{pair} #{pairs[i + 1]}"
              i = i + 1
            end

            if pair.index(' ')
              name, version = pair.split(' ', 2)
              result << { 'name' => name, 'version' => version }
            else
              result << { 'name' => pair }
            end

          end

          result
        end

      end
    end
  end
end
