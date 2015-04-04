#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Package\Loader\JsonLoader.php
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

      # Loads a package from a json string or JsonFile
      # @author Ioannis Kappas <ikappas@devworks.gr>
      # @php_author Konstantin Kudryashiv <ever.zet@gmail.com>
      class JsonLoader

        def initialize(loader)
          @loader = loader
        end

        # Load a json string or file
        # Param:  string|JsonFile json A filename, json string or JsonFile instance to load the package from
        # Returns: Composer::Package::Package
        def load(json)
          if json.instance_of?(Composer::Json::JsonFile)
            config = json.read
          elsif File.exist?(json)
            config = Composer::Json::JsonFile.parse_json(
              File.open(filepath, "r") { |f| f.read },
              json
            )
          elsif json.class === "String"
            config = Composer::Json::JsonFile.parse_json(
              json
            )
          end
          @loader.load(config)
        end

      end
    end
  end
end
