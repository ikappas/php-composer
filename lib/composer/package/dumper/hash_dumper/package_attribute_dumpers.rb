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

        attr_dumper :target_dir

        attr_dumper :source_type do |package, data|
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

        attr_dumper :dist_type do |package, data|
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
              dist_sha1_checksum = package.dist_sha1_checksum
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

        attr_dumper :archive_excludes do |package, data|
          archive_excludes = package.archive_excludes
          unless archive_excludes.nil? || archive_excludes.empty?
            data['archive'] = {}
            data['archive']['exclude'] = archive_excludes
          end
        end

        ::Composer::Package::SUPPORTED_LINK_TYPES.each do |type, opts|
          attr_dumper opts[:method] do |package, data|
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

        attr_dumper :suggests do |package, data|
          packages = package.suggests
          unless packages.nil? || packages.empty?
            packages.keys.sort.each do |k|
              packages[k] = packages.delete k
            end
            data['suggest'] = packages
          end
        end

        attr_dumper :release_date do |package, data|
          release_date = package.release_date
          unless release_date.nil?
            data['time'] = release_date.strftime('%Y-%m-%d %H:%M:%S')
          end
        end

        attr_dumper :binaries, to: 'bin'
        attr_dumper :type
        attr_dumper :extra
        attr_dumper :installation_source
        attr_dumper :autoload
        attr_dumper :dev_autoload, to: 'autoload-dev'
        attr_dumper :notification_url
        attr_dumper :include_paths, to: 'include-path'
        attr_dumper :transport_options

      end
    end
  end
end
