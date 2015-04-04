#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Package\Loader\ArrayLoader.php
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
      # Loads a package from a hash
      #
      # PHP Authors:
      # Konstantin Kudryashiv <ever.zet@gmail.com>
      # Jordi Boggiano <j.boggiano@seld.be>
      #
      # Ruby Authors:
      # Ioannis Kappas <ikappas@devworks.gr>
      class HashLoader
        def initialize(parser = nil, load_options = false)
          parser = Composer::Package::Version::VersionParser.new unless parser
          @version_parser = parser
          @load_options = load_options
        end

        def load(config, class_name = 'Composer::Package::CompletePackage')
          unless config
            raise ArgumentError,
                  'Invalid package configuration supplied.'
          end

          unless config.key?('name')
            raise UnexpectedValueError,
                  "Unknown package has no name defined (#{config.to_json})."
          end

          unless config.key?('version')
            raise UnexpectedValueError,
                  "Package #{config['name']} has no version defined."
          end

          # handle already normalized versions
          if config.key?('version_normalized')
            version = config['version_normalized']
          else
            version = @version_parser.normalize(config['version'])
          end

          package = Object.const_get(class_name).new(
            config['name'],
            version,
            config['version']
          )

          # parse type
          if config.key?('type')
            package.type = config['type'].downcase
          else
            package.type = 'library'
          end

          # parse target-dir
          if config.key?('target-dir')
            package.target_dir = config['target-dir']
          end

          # parse extra
          if config.key?('extra') && config['extra'].is_a?(Hash)
            package.extra = config['extra']
          end

          # parse bin
          if config.key?('bin')
            unless config['bin'].is_a?(Array)
              raise UnexpectedValueError,
                    "Package #{config['name']}'s bin key should be an hash, \
                    #{config['bin'].class.name} given."
            end
            config['bin'].each do |bin|
              bin.gsub!(/^\/+/, '')
            end
            package.binaries = config['bin']
          end

          # parse installation source
          if config.key?('installation-source')
            package.installation_source = config['installation-source']
          end

          # parse source
          if config.key?('source')
            if [:type, :url, :reference].all? {|k| config['source'].key? k}
              raise UnexpectedValueError,
                    "Package #{config['name']}'s source key should be \
                    specified as \
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

          #parse dist
          if config.key?('dist')
            if [:type, :url].all? {|k| config['dist'].key? k}
              raise UnexpectedValueError,
                    "Package #{config['name']}'s dist key should be \
                    specified as \
                    {\"type\": ..., \"url\": ..., \"reference\": ..., \"shasum\": ...},\n
                    #{config['dist'].to_json} given."
            end
            package.dist_type = config['dist']['type']
            package.dist_url = config['dist']['url']

            package.dist_reference = config['dist'].key?('reference') ?
                                      config['dist']['reference'] : nil

            package.dist_sha1_checksum = config['dist'].key?('shasum') ?
                                      config['dist']['shasum'] : nil

            if config['dist'].key?('mirrors')
              package.dist_mirrors = config['dist']['mirrors']
            end
          end

          # parse supported link types
          Composer::Package::BasePackage::SUPPORTED_LINK_TYPES.each do |type, opts|
            next if !config.key?(type)
            package.send(
              "#{opts['method']}=",
              @version_parser.parse_links(
                package.name,
                package.pretty_version,
                opts['description'],
                config[type]
              )
            )
          end

          # parse suggest
          if config.key?('suggest') && config['suggest'].is_a?(Hash)
            config['suggest'].each do |target, reason|
              if 'self.version' === reason.strip!
                config['suggest'][target] = package.pretty_version
              end
            end
            package.suggests = config['suggest']
          end

          # parse autoload
          if config.key? 'autoload'
            package.autoload = config['autoload']
          end

          # parse autoload-dev
          if config.key? 'autoload-dev'
            package.dev_autoload = config['autoload-dev']
          end

          # parse include-path
          if config.key? 'include-path'
            package.include_paths = config['include-path']
          end

          # parse time
          if !is_empty?(config, 'time')
            time = is_numeric?(config['time']) ? "@#{config['time']}" : config['time']
            begin
              date = Time.zone.parse(time)
              package.release_date = date
            rescue Exception => e
              log("Time Exception #{e}")
            end
          end

          # parse notification url
          if !is_empty?(config, 'notification-url')
            package.notification_url = config['notification-url']
          end

          # parse archive excludes
          if config.key?('archive') &&
             config['archive'].key?('exclude') &&
             !config['archive']['exclude'].empty?
            package.archive_excludes = config['archive']['exclude']
          end

          if package.instance_of?(Composer::Package::CompletePackage)

            # parse scripts
            if config.key?('scripts') && config['scripts'].is_a?(Array)
              config['scripts'].each do |event, listeners|
                config['scripts'][event] = Array(listeners)
              end
              package.scripts = config['scripts']
            end

            # parse description
            if !is_empty?(config, 'description') && config['description'].is_a?(String)
              package.description = config['description']
            end

            # parse homepage
            if !is_empty?(config, 'homepage') && config['homepage'].is_a?(String)
              package.homepage = config['homepage']
            end

            # parse keywords
            if !is_empty?(config, 'keywords') && config['keywords'].is_a?(Array)
              package.keywords = config['keywords']
            end

            # parse license
            if !is_empty?(config, 'license')
              package.license = config['license'].is_a?(Array) ? config['license'] : [config['license']]
            end

            # parse authors
            if !is_empty?(config, 'authors') && config['authors'].is_a?(Array)
              package.authors = config['authors']
            end

            # parse support
            if config.key?('support')
              package.support = config['support']
            end

            # parse abandoned
            if config.key?('abandoned')
              package.abandoned = config['abandoned']
            end

          end

          if alias_normalized = get_branch_alias(config)
            if package.instance_of?(Composer::Package::RootPackage)
              package = Composer::Package::RootAliasPackage.new(
                package,
                alias_normalized,
                alias_normalized.gsub(/(\.9{7})+/, '.x')
              )
            else
              package = Composer::Package::AliasPackage.new(
                package,
                alias_normalized,
                alias_normalized.gsub(/(\.9{7})+/, '.x')
              )
            end
          end

          if @load_options && config.key?('transport-options')
            package.transport_options = config['transport-options']
          end

          package
        end

        # Retrieves a branch alias
        # (dev-master => 1.0.x-dev for example) if it exists
        #
        # Params:
        # +config+ array The entire package config
        #
        # Returns:
        # string|nil normalized version of the branch alias
        # or null if there is none
        def get_branch_alias(config)
          return nil unless
            (config['version'].start_with?('dev-') || config['version'].end_with?('-dev')) &&
            config.key?('extra') &&
            config['extra'].key?('branch-alias') &&
            config['extra']['branch-alias'].is_a?(Hash)

          config['extra']['branch-alias'].each do |source_branch, target_branch|
            # ensure it is an alias to a -dev package
            next if !target_branch.end_with?('-dev')

            # normalize without -dev and ensure it's a numeric branch that is parseable
            validated_target_branch = @version_parser.normalize_branch(target_branch[0..-5])
            next if !validated_target_branch.end_with?('-dev')

            # ensure that it is the current branch aliasing itself
            next if config['version'].downcase != source_branch.downcase

            # If using numeric aliases ensure the alias is a valid subversion
            source_prefix = @version_parser.parse_numeric_alias_prefix(source_branch)
            target_prefix = @version_parser.parse_numeric_alias_prefix(target_branch)
            next if source_prefix && target_prefix && target_prefix.index(source_prefix) != 0 #(stripos($targetPrefix, $sourcePrefix) !== 0)

            return validated_target_branch
          end
          nil
        end

        private

        def is_numeric?(value)
          true if Float(value) rescue false
        end

        def is_empty?(config, key)
          config.key?(key) ? config[key].empty? : true
        end

      end
    end
  end
end
