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
      # Version Parser
      #
      # PHP Authors:
      # Jordi Boggiano <j.boggiano@seld.be>
      #
      # Ruby Authors:
      # Ioannis Kappas <ikappas@devworks.gr>
      class VersionParser
        MODIFIER_REGEX = '[._-]?(?:(stable|beta|b|RC|alpha|a|patch|pl|p)(?:[.-]?(\d+))?)?([.-]?dev)?'.freeze()

        class << self

          # Returns the stability of a version
          #
          # Params:
          # +version+:: string The version to parse for stability
          #
          # Returns:
          # string The version's stability
          def parse_stability(version)
            raise ArgumentError, 'version must be specified' unless version
            raise TypeError, 'version must be of type String' unless version.is_a?(String)
            raise UnexpectedValueError, 'version string must not be empty' if version.empty?

            version = version.gsub(/#.+$/i, '')

            if version.start_with?('dev-') || version.end_with?('-dev')
              return 'dev'
            end

            if matches = /#{MODIFIER_REGEX}$/i.match(version.downcase)
              if matches[3]
                return 'dev'
              elsif matches[1]
                if 'beta' === matches[1] || 'b' === matches[1]
                  return 'beta'
                elsif 'alpha' === matches[1] || 'a' === matches[1]
                  return 'alpha'
                elsif 'rc' === matches[1]
                  return 'RC'
                end
              end
            end

            'stable'
          end

          # Normalize the specified stability
          # Param: string stability
          # Return: string
          def normalize_stability(stability)
            raise ArgumentError, 'stability must be specified' unless stability
            raise TypeError, 'stability must be of type String' unless stability.is_a?(String)
            stability = stability.downcase
            stability === 'rc' ? 'RC' : stability
          end

          # Formats package version
          # Param: Composer::Package::Package package
          # Param: boolean truncate
          # Return: string
          def format_version(package, truncate = true)
            if !package.is_dev || !['hg', 'git'].include?(package.source_type)
              return package.pretty_version
            end

            # if source reference is a sha1 hash -- truncate
            if truncate && package.source_reference.length === 40
              return "#{package.pretty_version} #{package.source_reference[0..6]}"
            end

            "#{package.pretty_version} #{package.source_reference}"
          end
        end

        # Normalizes a version string to be able to perform comparisons on it
        #
        # Params:
        # +version+:: <tt>String</tt> The version string to normalize
        # +full_version+:: <tt>String</tt> optional complete version string to
        #                  give more context
        #
        # Throws:
        #   +InvalidVersionStringError+
        #
        # Returns:
        #   +String+
        def normalize(version, full_version = nil)
          raise ArgumentError, 'version must be specified' unless version
          raise TypeError, 'version must be of type String' unless version.is_a?(String)
          raise UnexpectedValueError, 'version string must not be empty' if version.empty?

          version.strip!
          if full_version == nil
            full_version = version
          end

          # ignore aliases and just assume the alias is required
          # instead of the source
          if matches = /^([^,\s]+) +as +([^,\s]+)$/.match(version)
            version = matches[1]
          end

          # ignore build metadata
          if matches = /^([^,\s+]+)\+[^\s]+$/.match(version)
            version = matches[1]
          end

          # match master-like branches
          if matches = /^(?:dev-)?(?:master|trunk|default)$/i.match(version)
            return '9999999-dev'
          end

          if 'dev-' === version[0...4].downcase
            return "dev-#{version[4..version.size]}"
          end

          # match classical versioning
          index = 0
          if matches = /^v?(\d{1,3})(\.\d+)?(\.\d+)?(\.\d+)?#{MODIFIER_REGEX}$/i.match(version)
            version = ''
            matches.to_a[1..4].each do |c|
              version += c ? c : '.0'
            end
            index = 5
          elsif matches = /^v?(\d{4}(?:[.:-]?\d{2}){1,6}(?:[.:-]?\d{1,3})?)#{MODIFIER_REGEX}$/i.match(version)
            version = matches[1].gsub(/\D/, '-')
            index = 2
          elsif matches = /^v?(\d{4,})(\.\d+)?(\.\d+)?(\.\d+)?#{MODIFIER_REGEX}$/i.match(version)
            version = ''
            matches.to_a[1..4].each do |c|
              version << (c.nil? ? '.0' : c)
            end
            index = 5
          end

          # add version modifiers if a version was matched
          if index > 0
            if matches[index]
              if 'stable' === matches[index]
                return version
              end
              stability = expand_stability(matches[index])
              version = "#{version}-#{stability ? stability : matches[index]}#{matches[index + 1] ? matches[index + 1] : ''}"
            end

            if matches[index + 2]
              version = "#{version}-dev"
            end

            return version
          end

          # match dev branches
          if matches = /(.*?)[.-]?dev$/i.match(version)
            begin
              return normalize_branch(matches[1])
            rescue
            end
          end

          extra_message = ''
          if matches = / +as +#{Regexp.escape(version)}$/.match(full_version)
            extra_message = " in \"#{full_version}\", the alias must be an exact version"
          elsif matches = /^#{Regexp.escape(version)} +as +/.match(full_version)
            extra_message = " in \"#{full_version}\", the alias source must be an exact version, if it is a branch name you should prefix it with dev-"
          end

          raise UnexpectedValueError, "Invalid version string \"#{version}\"#{extra_message}"
        end

        # Normalizes a branch name to be able to perform comparisons on it
        #
        # Params:
        # +name+:: string The branch name to normalize
        #
        # Returns:
        # string The normalized branch name
        def normalize_branch(name)
          name.strip!

          if ['master', 'trunk', 'default'].include?(name)
            return normalize(name)
          end

          if matches = /^v?(\d+)(\.(?:\d+|[xX*]))?(\.(?:\d+|[xX*]))?(\.(?:\d+|[xX*]))?$/i.match(name)
            version = ''

            # for i in 0..3
            #   # version << matches[i] ? matches[i].gsub('*', 'x').gsub('X', 'x') : '.x'
            # end
            matches.captures.each { |match| version << (match != nil ? match.gsub('*', 'x').gsub('X', 'x') : '.x') }
            return "#{version.gsub('x', '9999999')}-dev"
          end

          "dev-#{name}"
        end

        # Params:
        # +source+:: string source package name
        # +source_version+:: string source package version (pretty version ideally)
        # +description+:: string link description (e.g. requires, replaces, ..)
        # +links+:: array An array of package name => constraint mappings
        #
        # Returns:
        # Link[]
        def parse_links(source, source_version, description, links)
          res = {}
          links.each do |target, constraint|
            if 'self.version' === constraint
              parsed_constraint = parse_constraints(source_version)
            else
              parsed_constraint = parse_constraints(constraint)
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

        def parse_constraints(constraints)
          raise ArgumentError, 'version must be specified' unless constraints
          raise TypeError, 'version must be of type String' unless constraints.is_a?(String)
          raise UnexpectedValueError, 'version string must not be empty' if constraints.empty?

          pretty_constraint = constraints

          stabilites = Composer::Package::BasePackage.stabilities.keys.join('|')
          if match = /^([^,\s]*?)@(#{stabilites})$/i.match(constraints)
            constraints = match[1].nil? || match[1].empty? ? '*' : match[1]
          end

          if match = /^(dev-[^,\s@]+?|[^,\s@]+?\.x-dev)#.+$/i.match(constraints)
            constraints = match[1]
          end

          # or_constraints = preg_split('{\s*\|\|?\s*}', trim(constraints))
          or_constraints = constraints.strip.split(/\s*\|\|?\s*/)
          or_groups = []
          or_constraints.each do |constraints|

            # and_constraints = preg_split('{(?<!^|as|[=>< ,]) *(?<!-)[, ](?!-) *(?!,|as|$)}', constraints)
            and_constraints = constraints.split(/(?<!^|as|[=>< ,]) *(?<!-)[, ](?!-) *(?!,|as|$)/)

            if and_constraints.length > 1
                constraint_objects = []
                and_constraints.each do |constraint|
                  constraint_objects << parse_constraint(constraint)
                end
            else
              constraint_objects = parse_constraint(and_constraints[0])
            end

            if constraint_objects.length === 1
              constraint = constraint_objects[0]
            else
              constraint = Composer::Package::LinkConstraint::MultiConstraint.new(constraint_objects)
            end

            or_groups << constraint
          end

          if or_groups.length === 1
            constraint = or_groups[0]
          else
            constraint = Composer::Package::LinkConstraint::MultiConstraint.new(or_groups, false)
          end

          constraint.pretty_string = pretty_constraint

          constraint
        end

        # Extract numeric prefix from alias, if it is in numeric format,
        # suitable for version comparison
        #
        # Params:
        # +branch+:: string Branch name (e.g. 2.1.x-dev)
        #
        # Returns:
        # string|false Numeric prefix if present (e.g. 2.1.) or false
        def parse_numeric_alias_prefix(branch)
          if matches = /^(?<version>(\d+\.)*\d+)(?:\.x)?-dev$/i.match(branch)
            return "#{matches['version']}."
          end
          false
        end

        # Parses a name/version pairs and returns an array of pairs + the
        #
        # Params:
        # +pairs+:: array a set of package/version pairs separated by ":", "=" or " "
        #
        # Returns:
        # array[] array of arrays containing a name and (if provided) a version
        def parse_name_version_pairs(pairs)
          pairs = pairs.values
          result = []

          for i in 0..(pairs.length - 1)
            pair = pairs[i].strip!.gsub(/^([^=: ]+)[=: ](.*)$/, '$1 $2')
            if nil === pair.index(' ') && pairs.key?(i + 1) && nil === pairs[i + 1].index('/')
              pair = "#{pair} #{pairs[i + 1]}"
              i = i + 1
            end

            if pair.index(' ')
              name, version = pair.split(' ', 2)
              result << { 'name' => name, 'version' => version }
            else
              result << { 'name' => pair }
            end

          end

          result
        end

        # PRIVATE METHODS
        private

        def parse_constraint(constraint)

          stabilites = Composer::Package::BasePackage.stabilities.keys.join('|')
          if match = /^([^,\s]+?)@(#{stabilites})$/i.match(constraint)
            constraint = match[1]
            if match[2] != 'stable'
              stability_modifier = match[2]
            end
          end

          if /^[xX*](\.[xX*])*$/i.match(constraint)
            return [
              Composer::Package::LinkConstraint::EmptyConstraint.new
            ]
          end

          version_regex = '(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?' + MODIFIER_REGEX

          # match tilde constraints
          # like wildcard constraints, unsuffixed tilde constraints say that they must be greater than the previous
          # version, to ensure that unstable instances of the current version are allowed.
          # however, if a stability suffix is added to the constraint, then a >= match on the current version is
          # used instead
          if matches = /^~>?#{version_regex}$/i.match(constraint)

            if constraint[0...2] === '~>'
              raise UnexpectedValueError,
                  "Could not parse version constraint #{constraint}: \
                  Invalid operator \"~>\", you probably meant to use the \"~\" operator"
            end

            # Work out which position in the version we are operating at
            if matches[4] && matches[4] != ''
                position = 4
            elsif matches[3] && matches[3] != ''
                position = 3
            elsif matches[2] && matches[2] != ''
                position = 2
            else
                position = 1
            end

            # Calculate the stability suffix
            stability_suffix = ''
            if !matches[5].nil? && !matches[5].empty?
              stability_suffix << "-#{expand_stability(matches[5])}"
              if !matches[6].nil? && !matches[6].empty?
                stability_suffix << matches[6]
              end
            end

            if !matches[7].nil? && !matches[7].empty?
              stability_suffix << '-dev'
            end

            stability_suffix = '-dev' if stability_suffix.empty?

            low_version = manipulate_version_string(matches.to_a, position, 0) + stability_suffix
            lower_bound = Composer::Package::LinkConstraint::VersionConstraint.new('>=', low_version)

            # For upper bound, we increment the position of one more significance,
            # but high_position = 0 would be illegal
            high_position = [1, position - 1].max
            high_version = manipulate_version_string(matches.to_a, high_position, 1) + '-dev'
            upper_bound = Composer::Package::LinkConstraint::VersionConstraint.new('<', high_version)

            return [
              lower_bound,
              upper_bound
            ]
          end

          # match caret constraints
          if matches = /^\^#{version_regex}($)/i.match(constraint)
            # Create comparison array
            has_match = []
            for i in 0..(matches.to_a.length - 1)
              has_match[i] = !matches[i].nil? && !matches[i].empty?
            end

            # Work out which position in the version we are operating at
            if matches[1] != '0' || !has_match[2]
              position = 1
            elsif matches[2] != '0' || !has_match[3]
              position = 2
            else
              position = 3
            end

            # Calculate the stability suffix
            stability_suffix = ''
            if !has_match[5] && !has_match[7]
              stability_suffix << '-dev'
            end

            low_pretty = "#{constraint}#{stability_suffix}"
            low_version = normalize(low_pretty[1..low_pretty.length - 1])
            lower_bound = Composer::Package::LinkConstraint::VersionConstraint.new('>=', low_version)

            # For upper bound, we increment the position of one more significance,
            # but high_position = 0 would be illegal
            high_version = manipulate_version_string(matches.to_a, position, 1) + '-dev'
            upper_bound = Composer::Package::LinkConstraint::VersionConstraint.new('<', high_version)

            return [
              lower_bound,
              upper_bound
            ]
          end

          # match wildcard constraints
          if matches = /^(\d+)(?:\.(\d+))?(?:\.(\d+))?\.[xX*]$/.match(constraint)
            if matches[3] && matches[3] != ''
              position = 3
            elsif matches[2] && matches[2] != ''
              position = 2
            else
              position = 1
            end

            low_version = manipulate_version_string(matches.to_a, position) + '-dev'
            high_version = manipulate_version_string(matches.to_a, position, 1) + '-dev'

            if low_version === "0.0.0.0-dev"
              return [Composer::Package::LinkConstraint::VersionConstraint.new('<', high_version)]
            end

            return [
              Composer::Package::LinkConstraint::VersionConstraint.new('>=', low_version),
              Composer::Package::LinkConstraint::VersionConstraint.new('<', high_version),
            ]
          end

          # match hyphen constraints
          if matches = /^(#{version_regex}) +- +(#{version_regex})($)/i.match(constraint)

            match_from = matches[1]
            match_to = matches[9]

            # Create comparison array
            has_match = []
            for i in 0..(matches.to_a.length - 1)
              has_match[i] = !matches[i].nil? && !matches[i].empty?
            end

            # Calculate the stability suffix
            low_stability_suffix = ''
            if !has_match[6] && !has_match[8]
              low_stability_suffix = '-dev'
            end

            low_version = normalize(match_from)
            lower_bound = Composer::Package::LinkConstraint::VersionConstraint.new('>=', low_version + low_stability_suffix)

            # high_version = matches[10]

            if (has_match[11] && has_match[12]) || has_match[14] || has_match[16]
              high_version = normalize(match_to)
              upper_bound = Composer::Package::LinkConstraint::VersionConstraint.new('<=', high_version)
            else
              high_match = ['', matches[10], matches[11], matches[12], matches[13]]
              high_version = manipulate_version_string(high_match, (!has_match[11] ? 1 : 2), 1) + '-dev'
              upper_bound = Composer::Package::LinkConstraint::VersionConstraint.new('<', high_version)
            end

            return [
              lower_bound,
              upper_bound
            ]
          end

          # match operators constraints
          if matches = /^(<>|!=|>=?|<=?|==?)?\s*(.*)/.match(constraint)
            begin
              version = normalize(matches[2])
              stability = VersionParser::parse_stability(version)
              if !stability_modifier.nil? && !stability_modifier.empty? && (stability === 'stable')
                version << "-#{stability_modifier}"
              elsif matches[1] === '<'
                unless /-#{MODIFIER_REGEX}$/.match(matches[2].downcase)
                  version << '-dev'
                end
              end
              operator = matches[1].nil? ? '=' : matches[1]
              return [Composer::Package::LinkConstraint::VersionConstraint.new(operator, version)]
            rescue Exception => e
            end
          end

          message = "Could not parse version constraint #{constraint}"
          message << ": #{e.message}" if e
          raise UnexpectedValueError, message
        end

        # Increment, decrement, or simply pad a version number.
        # Support function for {@link parse_constraint()}
        #
        # Params:
        # +matches+ Array with version parts in array indexes 1,2,3,4
        # +position+ Integer 1,2,3,4 - which segment of the version to decrement
        # +increment+ Integer
        # +pad+ String The string to pad version parts after position
        #
        # Returns:
        # string The new version
        def manipulate_version_string(matches, position, increment = 0, pad = '0')
          4.downto(1).each do |i|
            if i > position
              matches[i] = pad
            elsif i == position && increment
              matches[i] = matches[i].to_i + increment
              # If matches[i] was 0, carry the decrement
              if matches[i] < 0
                matches[i] = pad
                position -= 1

                # Return nil on a carry overflow
                return nil if i == 1
              end
            end
          end
          "#{matches[1]}.#{matches[2]}.#{matches[3]}.#{matches[4]}"
        end

        def expand_stability(stability)
          stability = stability.downcase
          case stability
          when 'a'
            'alpha'
          when 'b'
            'beta'
          when 'p', 'pl'
            'patch'
          when 'rc'
            'RC'
          else
            stability
          end
        end
      end
    end
  end
end
