#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Repository\RepositoryInterface.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Repository
    # Base repository.
    #
    # PHP Authors:
    # Nils Adermann <naderman@naderman.de>
    # Konstantin Kudryashov <ever.zet@gmail.com>
    # Jordi Boggiano <j.boggiano@seld.
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class BaseRepository
      SEARCH_FULLTEXT = 0
      SEARCH_NAME = 1

      def package?
        # implement inside child
      end

      def find_package(name, version)
        # implement inside child
      end

      def find_packages(name, version = nil)
        # implement inside child
      end

      def packages
        # implement inside child
      end

      def search(query, mode = 0)
        # implement inside child
      end
    end
  end
end
