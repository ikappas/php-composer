#
# This file was ported to ruby from Composer php source code.
#
# Original Source: Composer\Package\Dumper\ArrayDumper.php
# Ref SHA: 346133d2a112dbc52163eceeee67814d351efe3f
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

      # Dumps a hash from a package
      #
      # PHP Authors:
      # Konstantin Kudryashiv <ever.zet@gmail.com>
      # Jordi Boggiano <j.boggiano@seld.be>
      #
      # Ruby Authors:
      # Ioannis Kappas <ikappas@devworks.gr>
      class HashDumper

        class << self

          def attr_dumpers
            @attr_dumpers ||= []
          end

          def attr_dumper( attr, options = {}, &block)
            if block_given?
              attr_dumpers.push({ attr: attr, options: options, callback: block })
            else
              attr_dumpers.push({ attr: attr, options: options })
            end
          end

        end

        def dump(package)

          # verify supplied arguments
          unless package
            raise ArgumentError,
                  'Invalid package configuration supplied.'
          end

          unless package.respond_to?(:pretty_name)
            raise UnexpectedValueError,
                  'The package specified is missing the "pretty_name" method.'
          end

          unless package.respond_to?(:pretty_version)
            raise UnexpectedValueError,
                  'The package specified is missing the "pretty_version" method.'
          end

          unless package.respond_to?(:version)
            raise UnexpectedValueError,
                  'The package specified is missing the "version" method.'
          end

          data = {}
          data['name'] = package.pretty_name
          data['version'] = package.pretty_version
          data['version_normalized'] = package.version

          # load class specific attributes
          HashDumper.attr_dumpers.each do |dumper|
            if package.respond_to? dumper[:attr]
              if dumper[:callback]
                instance_exec package, data, &dumper[:callback]
              else
                attr_value = package.send dumper[:attr]
                unless attr_value.nil? || attr_value.empty?
                  if dumper[:options][:to]
                    attr_key = dumper[:options][:to]
                  else
                    attr_key = dumper[:attr].to_s.tr('_', '-')
                  end
                  data[attr_key] = attr_value
                end
              end
            end
          end

          data
        end

        require_relative 'hash_dumper/package_attribute_dumpers'
        require_relative 'hash_dumper/complete_package_attribute_dumpers'
        require_relative 'hash_dumper/root_package_attribute_dumpers'

      end
    end
  end
end
