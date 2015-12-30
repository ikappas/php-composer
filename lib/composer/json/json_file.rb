#
# This file was ported to ruby from Composer php source code file.
#
# Original Source: Composer\Json\JsonFile.php
# Ref SHA: ce085826711a6354024203c6530ee0b56fea9c13
#
# (c) Nils Adermann <naderman@naderman.de>
#     Jordi Boggiano <j.boggiano@seld.be>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

require 'json-schema'

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
      attr :rfs, :json_last_error

      private :rfs, :json_last_error

      LAX_SCHEMA = 1
      STRICT_SCHEMA = 2

      JSON_UNESCAPED_SLASHES = 64
      JSON_PRETTY_PRINT = 128
      JSON_UNESCAPED_UNICODE = 256

      # Initializes json file reader/parser.
      #
      # @param [String] path path to a json file
      # @param [RemoteFileSystem] rfs The remote filesystem to use for http/https json files
      # @raise [ArgumentError]
      def initialize(path, rfs = nil)
        @path = path
        if rfs.nil? && /^https?:\/\//i.match(path)
          raise ArgumentError,
                'http urls require a RemoteFilesystem instance to be passed'
        end
        @rfs = rfs
        @json_last_error = nil
      end

      # Checks whether this json file exists.
      #
      # Returns:
      #   true if this json file exists; otherwise false.
      def exists?
        File.exists?(@path)
      end

      # Reads the json file.
      #
      # Raises:
      #   RuntimeError on error.
      #
      # Returns:
      #   mixed
      def read

        begin

          if @rfs
            json = @rfs.get_contents(@path, @path, false)
          else
            json = File.open(@path, 'r') { |f| f.read }
          end

        # rescue TransportError => e
        #   raise RuntimeError, e.message

        rescue => e
          raise RuntimeError,
                "Could not read #{@path}\n\n #{e.message}"
        end

        ::Composer::Json::JsonFile::parse_json(json, @path)
      end

      # Writes the json file.
      #
      # @param hash The hash to write to the json file.
      # @param options The options to use
      def write(hash, options = 448)

        dir = File.dirname(@path)
        unless File.directory?(dir)
          if File.exists?(dir)
            raise ::Composer::UnexpectedValueError,
                  "#{dir} exists and is not a directory."
          end
          unless FileUtils.mkdir_p(dir, mode: 0777) == 0
            raise ::Composer::UnexpectedValueError,
                  "#{dir} does not exist and could not be created."
          end
        end

        retries = 3
        while retries >= 0
          begin

            file_ending = ((options & JSON_PRETTY_PRINT).equal? JSON_PRETTY_PRINT) ? "\n" : ''
            File.open(@path, 'w') do |f|
              content = self.class.encode(hash, options) + file_ending
              f.write(content)
            end
            break

          rescue => e
            raise e unless retries > 0
            retries -= 1
            sleep 0.5
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

        if data.nil? && content != 'null'
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
          schema_data['required'] = [] # TODO: Check this!
          # schema_data['properties']['name']['required'] = false
          # schema_data['properties']['description']['required'] = false
        end

        errors = JSON::Validator.fully_validate(
          schema_data,
          data,
          { errors_as_objects: true }
        )

        unless errors.empty?
          processed_errors = []
          errors.each do |error|
            prefix = error[:fragment] ? "#{error[:fragment]} : " : ''
            processed_errors.push( prefix + error[:message])
          end
          raise ::Composer::Json::JsonValidationError.new(processed_errors),
                %Q("#{@path}" does not match the expected JSON schema)
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

          # WARNING: This function deviates from the original!

          json_last_error = nil

          if data.nil?
            return 'null'
          elsif data.is_a? TrueClass
            return 'true'
          elsif data.is_a? FalseClass
            return 'false'
          elsif data.is_a? Integer
            return Integer(data)
          elsif data.is_a? Float
            return Float(data)
          else
            begin
              json = JSON.generate data, quirks_mode: false
            rescue JSON::GeneratorError => e
              json_last_error = e
              if e.message === 'only generation of JSON objects or arrays allowed'
                begin
                  #trick into parsing scalar values by wrapping them in an array
                  scalar = data.gsub("\\\\", "\\\\\\")
                  json = JSON::generate [scalar], quirks_mode: false
                  unless json.nil?
                    json = json[1..(json.length - 2)]
                    json_last_error = nil
                  end
                rescue
                  # don't do anything (will report original error)
                end
              end
            end
          end

          unless json_last_error.nil?
            raise RuntimeError, json_last_error.message
          end

          pretty_print = ( options & JSON_PRETTY_PRINT ).equal? JSON_PRETTY_PRINT
          unescape_unicode = ( options & JSON_UNESCAPED_UNICODE ).equal? JSON_UNESCAPED_UNICODE
          unescape_slashes = ( options & JSON_UNESCAPED_SLASHES ).equal? JSON_UNESCAPED_SLASHES

          return json unless pretty_print or unescape_unicode or unescape_slashes
          ::Composer::Json::JsonFormatter::format(json, unescape_unicode, unescape_slashes)
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

          # WARNING: This function deviates from the original!

          return if json.nil?

          @json_last_error = nil
          begin
            data = JSON.parse json
          rescue JSON::ParserError => e
            @json_last_error = e
          end

          if data.nil? && !@json_last_error.nil?
            validate_syntax(json, file)
          else
            data
          end

        end

        def validate_syntax(_json, file = nil)

          # WARNING: This function deviates from the original!

          # TODO:
          # parser = Composer::Json::JsonParser.new
          # if (result = parser.lint(json))
          #   raise ParsingError,
          #       "\"#{file}\" does not contain valid JSON\n
          #       #{result.message}"
          # end
          # if (defined('JSON_ERROR_UTF8') && JSON_ERROR_UTF8 === json_last_error()) {
          #     throw new \UnexpectedValueException('"'.$file.'" is not UTF-8, could not parse as JSON');
          # }

          unless @json_last_error.nil?
            if file.nil?
              error_msg = %Q("#{file}" does not contain valid JSON\n#{@json_last_error.message})
            else
              error_msg = %Q("JSON string does not contain valid JSON\n#{@json_last_error.message})
            end

            raise JSON::ParserError, error_msg
          end

          true
        end
      end
    end
  end
end
