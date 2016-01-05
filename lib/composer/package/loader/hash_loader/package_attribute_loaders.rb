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

        attr_loader :type do |config, package|
          if config.key? 'type'
            package.type = config['type'].downcase
          else
            package.type = 'library'
          end
        end

        attr_loader :target_dir

        attr_loader :extra do |config, package|
          if config.key?('extra') && config['extra'].is_a?(Hash)
            package.extra = config['extra']
          end
        end

        attr_loader :binaries do |config, package|
          if config.key?('bin')
            unless config['bin'].is_a?(Array)
              raise UnexpectedValueError,
                    "Package #{config['name']}'s bin key should be an hash,\n
                    #{config['bin'].class.name} given."
            end
            config['bin'].each do |bin|
              bin.gsub!(/^\/+/, '')
            end
            package.binaries = config['bin']
          end
        end

        attr_loader :installation_source

        attr_loader :source do |config, package|
          if config.key?('source')
            if [:type, :url, :reference].all? {|k| config['source'].key? k}
              raise UnexpectedValueError,
                    "Package #{config['name']}'s source key should be specified as\n
                    {\"type\": ..., \"url\": ..., \"reference\": ...}, \n
                    #{config['source'].to_json} given."
            end
            package.source_type = config['source']['type']
            package.source_url = config['source']['url']
            package.source_reference = config['source']['reference']
            if config['source'].key?('mirrors')
              package.source_mirrors = config['source']['mirrors']
            end
          end
        end

        attr_loader :dist do |config, package|
          if config.key?('dist')
            if [:type, :url].all? {|k| config['dist'].key? k}
              raise UnexpectedValueError,
                    "Package #{config['name']}'s dist key should be specified as\n
                    {\"type\": ..., \"url\": ..., \"reference\": ..., \"shasum\": ...},\n
                    #{config['dist'].to_json} given."
            end
            package.dist_type = config['dist']['type']
            package.dist_url = config['dist']['url']
            package.dist_reference = config['dist'].key?('reference') ? config['dist']['reference'] : nil
            package.dist_sha1_checksum = config['dist'].key?('shasum') ? config['dist']['shasum'] : nil
            if config['dist'].key?('mirrors')
              package.dist_mirrors = config['dist']['mirrors']
            end
          end
        end

        SUPPORTED_LINK_TYPES.each do |type, opts|
          attr_loader opts[:method] do |config, package|
            if config.key?(type)
              package.send(
                "#{opts[:method]}=",
                parse_links(
                  package.name,
                  package.pretty_version,
                  opts[:description],
                  config[type]
                )
              )
            end
          end
        end

        attr_loader :suggests do |config, package|
          if config.key?('suggest') && config['suggest'].is_a?(Hash)
            config['suggest'].each do |target, reason|
              if 'self.version' === reason.strip!
                config['suggest'][target] = package.pretty_version
              end
            end
            package.suggests = config['suggest']
          end
        end

        attr_loader :autoload

        attr_loader :dev_autoload, from: 'autoload-dev'

        attr_loader :include_paths, from: 'include-path'

        attr_loader :release_date, from: 'time' do |config, package|
          if config.key?('time')
            unless config['time'].empty?
              time = config['time'] =~ /[[:digit:]]/ ? "@#{config['time']}" : config['time']
              date = Time.zone.parse(time) rescue false
              package.release_date = date unless date
            end
          end
        end

        attr_loader :notification_url do |config, package|
          if config.key?('notification-url')
            unless config['notification-url'].empty?
              package.notification_url = config['notification-url']
            end
          end
        end

        attr_loader :archive_excludes do |config, package|
          if config.key?('archive')
            if config['archive'].key?('exclude')
              unless config['archive']['exclude'].empty?
                package.archive_excludes = config['archive']['exclude']
              end
            end
          end
        end

        ##
        # @param  source string
        #   The source package name
        # @param  source_version string
        #   The source package version (pretty version ideally)
        # @param  description string
        #   The link description (e.g. requires, replaces, ..)
        # @param  links hash
        #   The hash of package name => constraint mappings
        #
        # @return Link{}
        ##
        def parse_links(source, source_version, description, links)
          res = {}
          links.each do |target, constraint|
            if 'self.version' === constraint
              parsed_constraint = @version_parser.parse_constraints(source_version)
            else
              parsed_constraint = @version_parser.parse_constraints(constraint)
            end
            res[target.downcase] = Composer::Package::Link.new(
              source,
              target,
              parsed_constraint,
              description,
              constraint
            )
          end
          res
        end

      end
    end
  end
end
