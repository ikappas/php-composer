#
# This file was ported to ruby from Composer php source code file.
#
# Original Source: Composer\Json\JsonFormatter.php
# Ref SHA: ce085826711a6354024203c6530ee0b56fea9c13
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Json

    #  * Formats json strings used for php < 5.4 because the json_encode doesn't
    #  * supports the flags JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE
    #  * in these versions
    #
    # PHP Authors:
    # Konstantin Kudryashiv <ever.zet@gmail.com>
    # Jordi Boggiano <j.boggiano@seld.be>
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class JsonFormatter

      class << self

        # This code is based on the function found at:
        # http://recursive-design.com/blog/2008/03/11/format-json-with-php/
        #
        # Originally licensed under MIT by Dave Perrett <mail@recursive-design.com>
        #
        # @param json string
        # @param unescape_unicode bool Whether to unescape unicode
        # @param unescape_slashes bool  Whether to unescape slashes
        # @return string
        def format(json, unescape_unicode, unescape_slashes)

          result = ''
          pos = 0
          str_len = json.length
          indent_str = '    '
          new_line = "\n"
          out_of_quotes = true
          buffer = ''
          no_escape = true
          
          for i in 0..(str_len - 1)

            # grab the next character in the string
            char = json[i]

            # are we inside a quoted string?
            if char === '"' && no_escape
              out_of_quotes = !out_of_quotes
            end

            if !out_of_quotes
              buffer << char
              no_escape = '\\' === char ? !no_escape : true
              next

            elsif !buffer.empty?

              if unescape_slashes
                buffer.gsub!('\\/', '/')
              end

              if unescape_unicode
                buffer.gsub!(/\\u([\da-fA-F]{4})/) {|m| [$1].pack('H*').unpack('n*').pack('U*')}
              end

              result << buffer + char
              buffer = ''
              next

            end

            if char === ':'
              # Add a space after the : character
              char << ' '

            elsif char === '}' || char === ']'

              pos -= 1
              prev_char = json[i - 1]

              if prev_char != '{' && prev_char != '['
                # If this character is the end of an element,
                # output a new line and indent the next line
                result << new_line

                for j in 0..(pos - 1)
                  result << indent_str
                end
              else
                # Collapse empty {} and []
                result.rstrip!
              end
            end

            result << char

            # If the last character was the beginning of an element,
            # output a new line and indent the next line
            if char === ',' || char === '{' || char === '['
              result << new_line
              pos += 1 if char === '{' || char === '['
              for j in 0..(pos - 1)
                result << indent_str
              end
            end

          end

          result
        end

      end
    end
  end
end
