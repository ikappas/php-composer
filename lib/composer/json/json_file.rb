#
# This file was ported to ruby from Composer php source code file.
# Original Source: Composer\Json\JsonFile.php
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Json
    # Reads/writes json files.
    #
    # PHP Authors:
    # Konstantin Kudryashiv <ever.zet@gmail.com>
    # Jordi Boggiano <j.boggiano@seld.be>
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class JsonFile
      attr_reader :path

      LAX_SCHEMA = 1
      STRICT_SCHEMA = 2

      JSON_ERROR_NONE = 0
      JSON_ERROR_DEPTH = 1
      JSON_ERROR_STATE_MISMATCH = 2
      JSON_ERROR_CTRL_CHAR = 3
      JSON_ERROR_SYNTAX = 4
      JSON_ERROR_UTF8 = 5
      JSON_ERROR_RECURSION = 6
      JSON_ERROR_INF_OR_NAN = 7
      JSON_ERROR_UNSUPPORTED_TYPE = 8

      # Initializes json file reader/parser.
      # @param [String] path path to a json file
      # @param [RemoteFileSystem] rfs The remote filesystem to use for http/https json files
      # @raise [ArgumentError]
      def initialize(path, rfs = nil)
        @path = path
        if rfs === nil && /^https?:\/\//i.match(path)
          raise ArgumentError,
                'http urls require a RemoteFilesystem instance to be passed'
        end
        @rfs = rfs
      end

      # Checks whether this json file exists.
      #
      # Returns:
      # true if this json file exists; otherwise false.
      def exists?
        File.exists?(path)
      end

      # Reads the json file.
      #
      # Raises:
      # RuntimeError
      #
      # Returns:
      # mixed
      def read
        if @rfs
          json = @rfs.get_contents(@path, @path, false)
        else
          json = File.open(@path, 'r') { |f| f.read }
        end

        parse_json(json, @path)

      rescue Exception => e
        raise e
      end

      def write(hash, options = 448)
        dir = File.dirname(@path)

        unless File.directory?(dir)
          if File.exists?(dir)
            raise UnexpectedValueError,
                  "#{dir} exists and is not a directory."
          end
          FileUtils.mkdir_p(dir, 0777)
        end

        retries = 3
        while retries >= 0
          begin
            file_ending = options & JSON_PRETTY_PRINT ? "\n" : ''
            File.open(path, 'w') do |f|
              content = encode(hash, options) + file_ending
              f.write(content)
            end
            break

          rescue Exception => e
            if retries
              retries -= 1
              sleep 0.5
            else
              raise e
            end
          end
        end

      end

      # Validates the schema of the current json file according
      # to composer-schema.json rules
      #
      # @param schema int a JsonFile::*_SCHEMA constant
      # @return bool true if schema is valid; Otherwise false.
      # @throw Composer::Json::JsonValidationError
      def validate_schema(schema = STRICT_SCHEMA)
        content = File.open(@path, 'r') { |f| f.read }
        data = JSON.parse(content)

        if data == nil && content != 'null'
          self::validate_syntax(content, @path)
        end

        schema_file = File.join(
          File.dirname(__FILE__),
          '../../../resources/composer-schema.json'
        )

        schema_data = JSON.parse(
          File.open(schema_file, 'r') { |f| f.read }
        )

        if schema === LAX_SCHEMA
          schema_data['additionalProperties'] = true
          schema_data['properties']['name']['required'] = false
          schema_data['properties']['description']['required'] = false
        end

        errors = JSON::Validator.fully_validate(
          schema_data,
          data,
          {:errors_as_objects => true}
        )

        unless errors.empty?
          processed_errors = []
          errors.each do |error|
            prefix = error[:fragment] ? "#{error[:fragment]} : " : ''
            processed_errors.push( prefix + error[:message])
          end
          raise Composer::Json::JsonValidationError.new(processed_errors),
                "\"#{@path}\" does not match the expected JSON schema"
        end

        true
      end

      class << self

        # Encodes an hash into (optionally pretty-printed) JSON
        #
        # @param  data mixed Data to encode into a formatted JSON string
        # @param  options int json_encode options (defaults to JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)
        # @return string Encoded json
        def encode(data, options = 448)

          # if (version_compare(PHP_VERSION, '5.4', '>=')) {
          #     $json = json_encode(data, options);

          #     # compact brackets to follow recent php versions
          #     if (PHP_VERSION_ID < 50428 || (PHP_VERSION_ID >= 50500 && PHP_VERSION_ID < 50512) || (defined('JSON_C_VERSION') && version_compare(phpversion('json'), '1.3.6', '<'))) {
          #         $json = preg_replace('/\[\s+\]/', '[]', $json);
          #         $json = preg_replace('/\{\s+\}/', '{}', $json);
          #     }

          #     return $json;
          # }

          # * *indent*: a string used to indent levels (default: ''),
          # * *space*: a string that is put after, a : or , delimiter (default: ''),
          # * *space_before*: a string that is put before a : pair delimiter (default: ''),
          # * *object_nl*: a string that is put at the end of a JSON object (default: ''),
          # * *array_nl*: a string that is put at the end of a JSON array (default: ''),
          # * *allow_nan*: true if NaN, Infinity, and -Infinity should be
          #   generated, otherwise an exception is thrown if these values are
          #   encountered. This options defaults to false.
          # * *max_nesting*: The maximum depth of nesting allowed in the data
          #   structures from which JSON is to be generated. Disable depth checking
          #   with :max_nesting => false, it defaults to 100.

          if data.nil?
            return 'null'
          elsif data.is_a?(TrueClass)
            return 'true'
          elsif data.is_a?(FalseClass)
            return 'false'
          elsif data.is_a?(Integer)
            return Integer(data)
          elsif data.is_a?(Float)
            return Float(data)
          else
            begin
              json = JSON.generate(data, { quirks_mode: false })
            rescue JSON::GeneratorError => e
              if e.message === 'only generation of JSON objects or arrays allowed'
                #trick into parsing scalar values by wrapping them in an array
                scalar = data.gsub("\\\\", "\\\\\\")
                if json = JSON::generate([scalar])
                  json = json[1..(json.length - 2)]
                end
              end
            end
          end

          return json unless options

          result = Composer::Json::JsonFormatter::format(
            json,
            options
          )

          result
        end

        # Parses json string and returns hash.
        #
        # Params:
        # +json+ string The json string to parse
        # +file+ string The json file
        #
        # Returns:
        # mixed
        def parse_json(json, file = nil)
          last_error = JSON_ERROR_NONE

          begin
            data = JSON.parse(json)
          rescue Exception => e
            last_error = e
          end

          if data.nil? && last_error != JSON_ERROR_NONE
            validate_syntax(json, file)
            raise JSON::ParserError,
                "\"#{file}\" does not contain valid JSON\n
                #{last_error.message}"
          end

          data
        end

        def validate_syntax(json, file)
          # JSON::
          # parser = Composer::Json::JsonParser.new
          # if (result = parser.lint(json))
          #   raise ParsingError,
          #       "\"#{file}\" does not contain valid JSON\n
          #       #{result.message}"
          # end
          # if (defined('JSON_ERROR_UTF8') && JSON_ERROR_UTF8 === json_last_error()) {
          #     throw new \UnexpectedValueException('"'.$file.'" is not UTF-8, could not parse as JSON');
          # }
          true
        end
      end
    end
  end
end
