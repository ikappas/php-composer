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

        attr_loader :scripts do |config, package|
          if config.key?('scripts') && config['scripts'].is_a?(Array)
            config['scripts'].each do |event, listeners|
              config['scripts'][event] = Array(listeners)
            end
            package.scripts = config['scripts']
          end
        end

        attr_loader :description do |config, package|
          if config.key?('description') && config['description'].is_a?(String)
            unless config['description'].empty?
              package.description = config['description']
            end
          end
        end

        attr_loader :homepage do |config, package|
          if config.key?('homepage') && config['homepage'].is_a?(String)
            unless config['homepage'].empty?
              package.homepage = config['homepage']
            end
          end
        end

        attr_loader :keywords do |config, package|
          if config.key?('keywords') && config['keywords'].is_a?(Array)
            unless config['keywords'].empty?
              package.keywords = config['keywords']
            end
          end
        end

        attr_loader :license do |config, package|
          if config.key?('license')
            unless config['license'].empty?
              package.license = config['license'].is_a?(Array) ? config['license'] : [config['license']]
            end
          end
        end

        attr_loader :authors do |config, package|
          if config.key?('authors') && config['authors'].is_a?(Array)
            unless config['authors'].empty?
              package.authors = config['authors']
            end
          end
        end

        attr_loader :support do |config, package|
          if config.key?('support')
            package.support = config['support']
          end
        end

        attr_loader :abandoned do |config, package|
          if config.key?('abandoned')
            package.abandoned = config['abandoned']
          end
        end

      end
    end
  end
end
