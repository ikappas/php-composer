#
# This file was ported to ruby from Composer php source code.
# Original Source: Composer\Repository\RepositoryInterface.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

require 'digest'

module Composer
  module Util

    # Composer mirror utilities
    #
    # @author Jordi Boggiano <j.boggiano@seld.be>
    class ComposerMirror

      class << self

        def process_url(mirror_url, package_name, version, reference, type)

          unless reference.nil? || /^([a-f0-9]*|%reference%)$/ =~ reference
            reference = Digest::MD5.hexdigest(reference)
          end

          unless version.nil? || version.index('/') === nil
            version = Digest::MD5.hexdigest(version)
          end

          map = {
            '%package%' => package_name,
            '%version%' => version,
            '%reference%' => reference,
            '%type%' => type
          }

          re = Regexp.new(map.keys.map { |x| Regexp.escape(x) }.join('|'))

          mirror_url.gsub(re, map)
        end

        def process_git_url(mirror_url, package_name, url, type)

          case url
            when /^(?:(?:https?|git):\/\/github\.com\/|git@github\.com:)([^\/]+)\/(.+?)(?:\.git)?$/
              url = "gh-#{$1}/#{$2}"
            when /^https:\/\/bitbucket\.org\/([^\/]+)\/(.+?)(?:\.git)?\/?$/
              url = "bb-#{$1}/#{$2}"
            else
              url = url.gsub(/^\//, '').gsub(/\/$/, '').gsub(/[^a-z0-9_.-]/i, '-')
          end

          map = {
              '%package%' => package_name,
              '%normalizedUrl%' => url,
              '%type%' => type
          }

          re = Regexp.new(map.keys.map { |x| Regexp.escape(x) }.join('|'))

          mirror_url.gsub(re, map)
        end

        def process_hg_url(mirror_url, package_name, url, type)
          process_git_url( mirror_url, package_name, url, type)
        end

      end

    end
  end
end
