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
    module Dumper
      class HashDumper

        attr_dumper :scripts
        attr_dumper :license
        attr_dumper :authors
        attr_dumper :description
        attr_dumper :homepage
        attr_dumper :repositories
        attr_dumper :support

        attr_dumper :keywords do |package, data|
          keywords = package.keywords
          unless keywords.nil? || keywords.empty?
            data['keywords'] = keywords.is_a?(Array) ? keywords.sort! : keywords
          end
        end

        attr_dumper :abandoned? do |package, data|
          if package.abandoned?
            replacement = true
            if package.respond_to?(:replacement_package)
              replacement = package.replacement_package
            end
            data['abandoned'] = replacement ? replacement : true
          end
        end

      end
    end
  end
end
