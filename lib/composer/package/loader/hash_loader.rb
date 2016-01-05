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

require 'composer/semver'

module Composer
  module Package
    module Loader

      ##
      # Loads a package from a hash
      #
      # PHP Authors:
      # Konstantin Kudryashiv <ever.zet@gmail.com>
      # Jordi Boggiano <j.boggiano@seld.be>
      #
      # Ruby Authors:
      # Ioannis Kappas <ikappas@devworks.gr>
      ##
      class HashLoader

        class << self

          def attr_loaders
            @attr_loaders ||= []
          end

          def attr_loader( attr, options = {}, &block)
            if block_given?
              attr_loaders.push({ attr: attr, options: options, callback: block })
            else
              attr_loaders.push({ attr: attr, options: options })
            end
          end

        end

        def initialize(parser = nil, load_options = false)
          parser ||= ::Composer::Semver::VersionParser.new

          unless parser.kind_of? (::Composer::Semver::VersionParser)
            raise ArgumentError,
                  'Invalid parser supplied.'
          end

          @version_parser = parser
          @load_options = load_options

        end

        def load(config, class_name = 'Composer::Package::CompletePackage')

          # verify supplied arguments
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

          # create the package based on the class specified
          package = Object.const_get(class_name).new(
            config['name'],
            version,
            config['version']
          )

          # load class specific attributes
          HashLoader.attr_loaders.each do |loader|
            package_attr = "#{loader[:attr]}="
            if package.respond_to? package_attr
              if loader[:callback]
                instance_exec config, package, &loader[:callback]
              else
                if loader[:options][:from]
                  config_key = loader[:options][:from]
                else
                  config_key = loader[:attr].to_s.gsub('_', '-')
                end

                if config.key? config_key
                  config_value = config[config_key]
                  unless config_value.nil? || config_value.empty?
                    package.send package_attr, config_value
                  end
                end
              end
            end
          end

          if (alias_normalized = get_branch_alias(config))
            if package.instance_of? ::Composer::Package::RootPackage
              alias_class = 'RootAliasPackage'
            else
              alias_class = 'AliasPackage'
            end
            package = Object.const_get("::Composer::Package::#{alias_class}").new(
              package,
              alias_normalized,
              alias_normalized.gsub(/(\.9{7})+/, '.x')
            )
          end

          if @load_options && config.key?('transport-options')
            package.transport_options = config['transport-options']
          end

          package
        end

        ##
        # Retrieves a branch alias if it exists.
        #
        # i.e.(dev-master => 1.0.x-dev)
        #
        # @param config array
        #   The entire package config
        #
        # @return string|nil
        # The normalized version of the branch alias or nil if there is none.
        ##
        def get_branch_alias(config)
          if config.key?('version') && (config['version'].start_with?('dev-') || config['version'].end_with?('-dev'))
            if config.key?('extra') && config['extra'].key?('branch-alias') && config['extra']['branch-alias'].is_a?(Hash)
              config['extra']['branch-alias'].each do |source_branch, target_branch|
                # ensure it is an alias to a -dev package
                next unless target_branch.end_with?('-dev')

                # normalize without -dev and ensure it's a numeric branch that is parseable
                validated_target_branch = @version_parser.normalize_branch(target_branch[0..-5])
                next unless validated_target_branch.end_with?('-dev')

                # ensure that it is the current branch aliasing itself
                next if config['version'].downcase != source_branch.downcase

                # If using numeric aliases ensure the alias is a valid subversion
                source_prefix = @version_parser.parse_numeric_alias_prefix(source_branch)
                target_prefix = @version_parser.parse_numeric_alias_prefix(target_branch)
                next if source_prefix && target_prefix && target_prefix.index(source_prefix) != 0 #(stripos($targetPrefix, sourcePrefix) !== 0)

                return validated_target_branch
              end
            end
          end
          nil
        end

        require_relative 'hash_loader/package_attribute_loaders'
        require_relative 'hash_loader/complete_package_attribute_loaders'
        require_relative 'hash_loader/root_package_attribute_loaders'

      end
    end
  end
end
