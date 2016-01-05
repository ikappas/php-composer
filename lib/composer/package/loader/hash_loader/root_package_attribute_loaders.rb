#
# This file was ported to ruby from Composer php source code.
#
# Original Source: Composer\Package\Loader\ArrayLoader.php
# Ref SHA: a1427d7fd626d4308c190a267dd7a993f87c6a2a
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package
    module Loader
      class HashLoader

        # on_load ::Composer::Package::RootPackage do |config, package|
        #
        #   if config.key?('minimum-stabitily')
        #     package.minimum_stability = config['minimum-stability']
        #   end
        #
        # end

        attr_loader :minimum_stability

      end
    end
  end
end
