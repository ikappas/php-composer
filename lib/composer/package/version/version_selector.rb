##
# This file was ported to ruby from Composer php source code file.
#
# Original Source: Composer\Package\Version\VersionSelector.php
# Ref SHA: 966a9827382b59064255579f524e3904527abdbe
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
##

module Composer
  module Package
    module Version

      ##
      # Selects the best possible version for a package
      #
      # PHP Authors:
      # Ryan Weaver <ryan@knpuniversity.com>
      #
      # Ruby Authors:
      # Ioannis Kappas <ikappas@devworks.gr>
      ##
      class VersionSelector

        def initialize(pool)
          @pool = pool
        end

        ##
        # Given a package name and optional version, returns the latest PackageInterface
        # that matches.
        #
        # @param _package_name string
        # @param _target_pkg_version string
        # @param _target_php_version string
        # @param _preferred_stability string
        #
        # @return Package|bool
        ##
        def find_best_candidate(_package_name, _target_pkg_version = nil, _target_php_version = nil, _preferred_stability = 'stable')

          raise NotImplementedError

          # constraint = target_pkg_version ? parser.parse_constraints(target_pkg_version) : nil
          # candidates = @pool.what_provides(package_name.downcase, constraint, true)
          #
          # if target_php_version
          #   php_constraint = ::Composer::Semver::Constraint::Constraint.new('==', parser.normalize(target_php_version))
          #   candidates = candidates.select do |pkg|
          #     requires = pkg.requires
          #     return ! requires['php'].nil? || requires['php'].constraint.matches(php_constraint)
          #   end
          # end
          #
          # return false unless candidates
          #
          # # select highest version if we have many
          # package = reset(candidates)
          # min_priority = ::Composer::Package::Package::stabilities[preferred_stability]
          # candidates.each do |candidate|
          #   candidate_priority = candidate.stability_priority
          #   current_priority = package.stability_priority
          #
          #   # candidate is less stable than our preferred stability, and we have a package that is more stable than it, so we skip it
          #   if min_priority < candidate_priority && current_priority < candidate_priority
          #     continue
          #   end
          #   # candidate is more stable than our preferred stability, and current package is less stable than preferred stability, then we select the candidate always
          #   if min_priority >= candidate_priority && min_priority < current_priority
          #     package = candidate
          #     continue
          #   end
          #
          #   # select highest version of the two
          #   if version_compare(package.version, candidate.version, '<')
          #     package = candidate
          #   end
          # end
          #
          # package
        end

        ##
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
        # @param package Package
        # @return string
        ##
        def find_recommended_require_version(package)
          version = package.version
          unless package.is_dev?
            return transform_version(version, package.pretty_version, package.stability)
          end

          loader = ::Composer::Package::Loader::HashLoader.new(parser)
          dumper = ::Composer::Package::Dumper::HashDumper.new

          extra = loader.get_branch_alias(dumper.dump(package))
          if extra =~ /^(\d+\.\d+\.\d+)(\.9999999)-dev$/
            extra = "#{$1}.0"
            extra.gsub!('.9999999', '.0')
            return transform_version(extra, extra, 'dev')
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
            version << "@#{stability}"
          end

          # 2.1 -> ~2.1
          op + version
        end

        def parser
          @parser ||= ::Composer::Semver::VersionParser.new
        end

      end
    end
  end
end
