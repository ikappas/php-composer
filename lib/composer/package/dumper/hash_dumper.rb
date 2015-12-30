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

        def dump(package)

          # verify supplied arguments
          unless package
            raise ArgumentError,
                  'Invalid package configuration supplied.'
          end

          unless package.respond_to?(:pretty_name)
            raise UnexpectedValueError,
                  %q(The package specified is missing the "pretty_name" method.)
          end

          unless package.respond_to?(:pretty_version)
            raise UnexpectedValueError,
                  %q(The package specified is missing the "pretty_version" method.)
          end

          unless package.respond_to?(:version)
            raise UnexpectedValueError,
                  %q(The package specified is missing the "version" method.)
          end

          data = {}
          data['name'] = package.pretty_name
          data['version'] = package.pretty_version
          data['version_normalized'] = package.version

          dump_package_target_dir!(package, data)
          dump_package_source!(package, data)
          dump_package_dist!(package, data)
          dump_package_archive!(package, data)
          dump_package_link_types!(package, data)
          dump_package_suggests!(package, data)
          dump_package_release_date!(package, data)
          dump_package_values!(package, data)
          dump_complete_package_values!(package, data)
          dump_root_package_values!(package, data)
          dump_package_transport_options!(package, data)

          sort_package_keywords!(data)
          data
        end

        private

        def dump_package_target_dir!(package, data)
          if package.respond_to? :target_dir
            target_dir = package.target_dir
            unless target_dir.nil? || target_dir.empty?
              data['target-dir'] = package.target_dir
            end
          end
        end

        def dump_package_source!(package, data)
          if package.respond_to? :source_type
            source_type = package.source_type
            unless source_type.nil? || source_type.empty?

              data['source'] = {}
              data['source']['type'] = package.source_type

              if package.respond_to? :source_url
                source_url = package.source_url
                unless source_url.nil? || source_url.empty?
                  data['source']['url'] = package.source_url
                end
              end

              if package.respond_to? :source_reference
                source_reference = package.source_reference
                unless source_reference.nil? || source_reference.empty?
                  data['source']['reference'] = source_reference
                end
              end

              if package.respond_to? :source_mirrors
                source_mirrors = package.source_mirrors
                unless source_mirrors.nil? || source_mirrors.empty?
                  data['source']['mirrors'] = source_mirrors
                end
              end

            end
          end
        end

        def dump_package_dist!(package, data)
          if package.respond_to? :dist_type
            dist_type = package.dist_type
            unless dist_type.nil? || dist_type.empty?

              data['dist'] = {}
              data['dist']['type'] = package.dist_type

              if package.respond_to? :dist_url
                dist_url = package.dist_url
                unless dist_url.nil? || dist_url.empty?
                  data['dist']['url'] = package.dist_url
                end
              end

              if package.respond_to? :dist_reference
                dist_reference = package.dist_reference
                unless dist_reference.nil? || dist_reference.empty?
                  data['dist']['reference'] = dist_reference
                end
              end

              if package.respond_to? :dist_sha1_checksum
                dist_sha1_checksum =  package.dist_sha1_checksum
                unless dist_sha1_checksum.nil? || dist_sha1_checksum.empty?
                  data['dist']['shasum'] = dist_sha1_checksum
                end
              end

              if package.respond_to? :dist_mirrors
                dist_mirrors = package.dist_mirrors
                unless dist_mirrors.nil? || dist_mirrors.empty?
                  data['dist']['mirrors'] = dist_mirrors
                end
              end

            end
          end
        end

        def dump_package_archive!(package, data)
          if package.respond_to?(:archive_excludes)
            archive_excludes = package.archive_excludes
            unless archive_excludes.nil? || archive_excludes.empty?
              data['archive'] = {}
              data['archive']['exclude'] = archive_excludes
            end
          end
        end

        def dump_package_link_types!(package, data)
          ::Composer::Package::SUPPORTED_LINK_TYPES.each do |type, opts|
            next unless package.respond_to? opts[:method]
            links = package.send(opts[:method])
            next if links.nil?
            next if links.is_a?(Array) && links.empty?
            next if links.is_a?(Hash) && links.empty?
            values = links.is_a?(Hash) ? links.values : links
            values.each do |link|
              data[type] = {} unless data.key?(type)
              data[type][link.target] = link.pretty_constraint
            end
            data[type].keys.sort.each do |k|
              data[type][k] = data[type].delete k
            end
          end
        end

        def dump_package_suggests!(package, data)
          if package.respond_to?(:suggests)
            packages = package.suggests
            unless packages.nil? || packages.empty?
              packages.keys.sort.each do |k|
                packages[k] = packages.delete k
              end
              data['suggest'] = packages
            end
          end
        end

        def dump_package_release_date!(package, data)
          if package.respond_to?(:release_date)
            release_date = package.release_date
            unless release_date.nil?
              data['time'] = release_date.strftime('%Y-%m-%d %H:%M:%S')
            end
          end
        end

        def dump_package_values!(package, data)

          keys = {
            binaries: 'bin',
            type:'type',
            extra: 'extra',
            installation_source: 'installation-source',
            autoload: 'autoload',
            dev_autoload: 'autoload-dev',
            notification_url: 'notification-url',
            include_paths: 'include-path',
          }

          dump_values!(package, keys, data)
        end

        def dump_complete_package_values!(package, data)

          keys = [
            :scripts,
            :license,
            :authors,
            :description,
            :homepage,
            :keywords,
            :repositories,
            :support,
          ]

          dump_values!(package, keys, data)
          dump_package_abandoned!(package, data)
        end

        def dump_package_abandoned!(package, data)
          if package.respond_to?(:abandoned?) && package.respond_to?(:replacement_package)
            if package.abandoned?
              replacement = package.replacement_package
              data['abandoned'] = replacement ? replacement : true
            end
          end
        end

        def dump_root_package_values!(package, data)

           keys = {
             minimum_stability: 'minimum-stability'
           }

           dump_values!(package, keys, data)
        end

        def dump_package_transport_options!(package, data)
          if package.respond_to?(:transport_options)
            transport_options = package.transport_options
            unless transport_options.nil? || transport_options.empty?
              data['transport-options'] = package.transport_options
            end
          end
        end

        def dump_values!(package, keys, data)
          keys.each do |method, key|

            next unless package.respond_to?(method)

            key ||= method.to_s
            value = package.send(method)
            next if value.nil?
            next if value.is_a?(Array) && value.empty?
            next if value.is_a?(Hash) && value.empty?

            data[key] = value

          end
        end

        def sort_package_keywords!(data)
          if data.key?('keywords') && data['keywords'].is_a?(Array)
            data['keywords'].sort!
          end
        end
      end
    end
  end
end
