#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Package\Version\VersionParser.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package
    module Version
      # Selects the best possible version for a package
      #
      # PHP Authors:
      # Ryan Weaver <ryan@knpuniversity.com>
      #
      # Ruby Authors:
      # Ioannis Kappas <ikappas@devworks.gr>
      class VersionSelector

          def initialize(pool)
            @pool = pool
          end


          # Given a concrete version, this returns a ~ constraint (when possible)
          # that should be used, for example, in composer.json.
          #
          # For example:
          #  * 1.2.1         -> ~1.2
          #  * 1.2           -> ~1.2
          #  * v3.2.1        -> ~3.2
          #  * 2.0-beta.1    -> ~2.0@beta
          #  * dev-master    -> ~2.1@dev      (dev version with alias)
          #  * dev-master    -> dev-master    (dev versions are untouched)
          #
          # @param  Package package
          # @return string
          def find_recommended_require_version(package)
            version = package.version
            if !package.is_dev
              return transform_version(version, package.pretty_version, package.stability)
            end

            loader = Composer::Package::Loader::HashLoader.new(parser)
            dumper = Composer::Package::Dumper::HashDumper.new

            if (extra = loader.get_branch_alias(dumper.dump(package)))
              if match = /^(\d+\.\d+\.\d+)(\.9999999)-dev$/.match(extra)
                extra = "#{match[1]}.0"
                extra.gsub!('.9999999', '.0')
                return transform_version(extra, extra, 'dev')
              end
            end

            package.pretty_version
          end

          private

          def transform_version(version, pretty_version, stability)
            # attempt to transform 2.1.1 to 2.1
            # this allows you to upgrade through minor versions
            semantic_version_parts = version.split('.')
            op = '~'

              # check to see if we have a semver-looking version
              if semantic_version_parts.length == 4 && /^0\D?/.match(semantic_version_parts[3])
                # remove the last parts (i.e. the patch version number and any extra)
                if semantic_version_parts[0] === '0'
                  if semantic_version_parts[1] === '0'
                    semantic_version_parts[3] = '*'
                  else
                    semantic_version_parts[2] = '*'
                    semantic_version_parts.delete_at(3)
                  end
                  op = ''
                else
                  semantic_version_parts.delete_at(3)
                  semantic_version_parts.delete_at(2)
                end
                version = semantic_version_parts.join('.')
              else
                return pretty_version
              end

              # append stability flag if not default
              if stability != 'stable'
                version <<  "@#{stability}"
              end

              # 2.1 -> ~2.1
              op + version
          end

          def parser
            @parser ||= Composer::Package::Version::VersionParser.new
            @parser
          end
      end
    end
  end
end
