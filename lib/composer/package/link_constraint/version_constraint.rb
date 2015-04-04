#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Package\LinkConstraint\VersionConstraint.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Package
    module LinkConstraint
      class VersionConstraint < SpecificConstraint
        attr_reader :operator, :version

        @@cache = nil

        # Sets operator and version to compare a package with
        # @param string $operator A comparison operator
        # @param string $version  A version to compare to
        def initialize(operator, version)
            if operator === '='
              operator = '=='
            end

            if operator === '<>'
              operator = '!='
            end

            @operator = operator
            @version = version
        end

        def version_compare(a, b, operator, compare_branches = false)

          a_is_branch = 'dev-' === a[0...4]
          b_is_branch = 'dev-' === b[0...4]
          if a_is_branch && b_is_branch
            return operator == '==' && a === b
          end

          # when branches are not comparable, we make sure dev branches never match anything
          if !compare_branches && (a_is_branch || b_is_branch)
            return false
          end

          # Standardise versions
          ver_a = a.strip.gsub(/([\-?\_?\+?])/, '.').gsub(/([^0-9\.]+)/, '.$1.').gsub(/\.\./, '.').split('.')
          ver_b = b.strip.gsub(/([\-?\_?\+?])/, '.').gsub(/([^0-9\.]+)/, '.$1.').gsub(/\.\./, '.').split('.')

          # Replace empty entries at the start of the array
          while ver_a[0] && ver_a[0].empty?
            ver_a.shift
          end
          while ver_b[0] && ver_b[0].empty?
            ver_b.shift
          end

          # Release state order
          # '#' stands for any number
          versions = {
            'dev'   => 0,
            'alpha' => 1,
            'a'     => 1,
            'beta'  => 2,
            'b'     => 2,
            'RC'    => 3,
            '#'     => 4,
            'p'     => 5,
            'pl'    => 5
          }

          # Loop through each segment in the version string
          compare = 0
          for i in 0..([ver_a.length, ver_b.length].min - 1)
          # for (i = 0, $x = [ver_a.length, ver_b.length].min; i < $x; i++) {

            next if ver_a[i] == ver_b[i]

            i1 = ver_a[i]
            i2 = ver_b[i]

            i1_is_numeric = true if Float(i1) rescue false
            i2_is_numeric = true if Float(i2) rescue false

            if i1_is_numeric && i2_is_numeric
              compare = (i1 < i2) ? -1 : 1
              break
            end

            # We use the position of '#' in the versions list
            # for numbers... (so take care of # in original string)
            if i1 == '#'
                i1 = ''
            elsif i1_is_numeric
              i1 = '#';
            end

            if i2 == '#'
              i2 = ''
            elsif i2_is_numeric
              i2 = '#'
            end

            if !versions[i1].nil? && versions[i2].nil?
              compare = versions[i1] < versions[i2] ? -1 : 1
            elsif !versions[i1].nil?
              compare = 1;
            elsif !versions[i2].nil?
              compare = -1;
            else
              compare = 0;
            end

            break;

          end

          # If previous loop didn't find anything, compare the "extra" segments
          if compare == 0
            if ver_b.length > ver_a.length
              if !ver_b[i].nil && !versions[ver_b[i]].nil
                compare = (versions[ver_b[i]] < 4) ? 1 : -1;
              else
                compare = -1;
              end
            elsif ver_b.length < ver_a.length
              if !ver_a[i].nil && !versions[ver_a[i]].nil
                compare = (versions[ver_a[i]] < 4) ? -1 : 1;
              else
                compare = 1;
              end
            end
          end

          # Compare the versions
          case operator
          when '>', 'gt'
            return compare > 0
          when '>=', 'ge'
            return compare >= 0
          when '<=', 'le'
            return compare <= 0
          when '==', '=', 'eq'
            return compare == 0
          when '<>', '!=', 'ne'
            return compare != 0
          when '', '<', 'lt'
            return compare < 0
          end

          false
        end

        # @param  VersionConstraint provider
        # @param  bool              compare_branches
        # @return bool
        def match_specific(provider, compare_branches = false)
          @@cache = {} unless @@cache
          @@cache[@operator] = {} unless @@cache.key?(@operator)
          @@cache[@operator][@version] = {} unless @@cache[@operator].key?(@version)
          @@cache[@operator][@version][provider.operator] = {} unless @@cache[@operator][@version].key?(provider.operator)
          @@cache[@operator][@version][provider.operator][provider.version] = {} unless @@cache[@operator][@version][provider.operator].key?(provider.version)

          if @@cache[@operator][@version][provider.operator][provider.version].key?(compare_branches)
            return @@cache[@operator][@version][provider.operator][provider.version][compare_branches]
          end

          (@@cache[@operator][@version][provider.operator][provider.version][compare_branches] = do_match_specific(provider, compare_branches))
        end

        def to_s
          "#{@operator} #{@version}"
        end

        private

        # /**
        #  * @param  VersionConstraint provider
        #  * @param  bool              compare_branches
        #  * @return bool
        def do_match_specific(provider, compare_branches = false)
          self_op_ne = @operator.gsub('=', '')
          provider_op_ne = provider.operator.gsub('=', '')

          self_op_is_eq = '==' === @operator
          self_op_is_ne = '!=' === @operator
          provider_op_is_eq = '==' === provider.operator
          provider_op_is_ne = '!=' === provider.operator

          # '!=' operator is match when other operator is not '==' operator or version is not match
          # these kinds of comparisons always have a solution
          if self_op_is_ne || provider_op_is_ne
            return !self_op_is_eq && !provider_op_is_eq ||
                version_compare(provider.version, @version, '!=', compare_branches)
          end

          # an example for the condition is <= 2.0 & < 1.0
          # these kinds of comparisons always have a solution
          if @operator != '==' && self_op_ne == provider_op_ne
            return true
          end

          if version_compare(provider.version, @version, @operator, compare_branches)
            # special case, e.g. require >= 1.0 and provide < 1.0
            # 1.0 >= 1.0 but 1.0 is outside of the provided interval
            if provider.version == @version && provider.operator == provider_op_ne && @operator != self_op_ne
              return false
            end

            return true
          end

          false
        end
      end
    end
  end
end