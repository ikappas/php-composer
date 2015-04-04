#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Package\Dumper\ArrayDumper.php
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
        def dump(package)
          keys = {
            'binaries' => 'bin',
            'type' => 'type',
            'extra' => 'extra',
            'installation_source' => 'installation-source',
            'autoload' => 'autoload',
            'dev_autoload' => 'autoload-dev',
            'notification_url' => 'notification-url',
            'include_paths' => 'include-path',
          }

          data = {}
          data['name'] = package.pretty_name
          data['version'] = package.pretty_version
          data['version_normalized'] = package.version

          if package.target_dir
            data['target-dir'] = package.target_dir
          end

          if package.source_type
            data['source'] = {}
            data['source']['type'] = package.source_type
            data['source']['url'] = package.source_url
            data['source']['reference'] = package.source_reference
            if mirrors = package.source_mirrors
              data['source']['mirrors'] = mirrors
            end
          end

          if package.dist_type
            data['dist'] = {}
            data['dist']['type'] = package.dist_type
            data['dist']['url'] = package.dist_url
            data['dist']['reference'] = package.dist_reference
            data['dist']['shasum'] = package.dist_sha1_checksum
            if mirrors = package.dist_mirrors
              data['dist']['mirrors'] = mirrors
            end
          end

          unless package.archive_excludes.nil? || package.archive_excludes.empty?
            data['archive'] = {}
            data['archive']['exclude'] = package.archive_excludes
          end

          Composer::Package::BasePackage::SUPPORTED_LINK_TYPES.each do |type, opts|
            next unless links = package.send(opts['method'])
            next if links.nil?
            next if links.is_a?(Array) && links.empty?
            next if links.is_a?(Hash) && links.empty?
            data[type] = {} unless data.key?(type)
            values = links.is_a?(Hash) ? links.values : links
            values.each do |link|
              data[type][link.target] = link.pretty_constraint
            end
            data[type].keys.sort.each do |k|
              data[type][k] = data[type].delete k
            end
          end

          if packages = package.suggests
            unless packages.nil? || packages.empty?
              packages.keys.sort.each do |k|
                packages[k] = packages.delete k
              end
              data['suggest'] = packages
            end
          end

          if package.release_date && !package.release_date.nil?
            data['time'] = package.release_date.strftime('%Y-%m-%d %H:%M:%S')
          end

          data = dump_values(package, keys, data)

          # if data.key?('type') && data['type'] === 'library'
          #   data.delete('type')
          # end

          if package.is_a?(Composer::Package::CompletePackage)
            keys = %w{scripts license authors description homepage keywords repositories support}
            data = dump_values(package, keys, data)

            if data.key?('keywords') && is_array?(data, 'keywords')
              data['keywords'].sort!
            end

            if package.is_abandoned?
              replacement = package.replacement_package
              data['abandoned'] = replacement ? replacement : true
            end
          end

          if package.is_a?(Composer::Package::RootPackage)
            minimum_stability = package.minimum_stability
            unless minimum_stability.nil? || minimum_stability.empty?
              data['minimum-stability'] = minimum_stability
            end
          end

          if !package.transport_options.nil? && package.transport_options.length > 0
            data['transport-options'] = package.transport_options
          end

          data
        end

        private

        def dump_values(package, keys, data)
          keys.each do |method, key|
            key = method unless key
            next unless  value  = package.send(method)
            next if value.nil?
            next if value.is_a?(Array) && value.empty?
            next if value.is_a?(Hash) && value.empty?
            data[key] = value
          end
          data
        end

        def is_numeric?(value)
          true if Float(value) rescue false
        end

        def is_empty?(config, key)
          config.key?(key) ? config[key].empty? : true
        end

        def is_hash?(config, key)
          config.key?(key) ? config[key].is_a?(Hash) : false
        end

        def is_array?(config, key)
          config.key?(key) ? config[key].is_a?(Array) : false
        end

        def is_string?(config, key)
          config.key?(key) ? config[key].is_a?(String) : false
        end
      end
    end
  end
end
