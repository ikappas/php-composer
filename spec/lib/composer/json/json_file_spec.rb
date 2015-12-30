require_relative '../../../spec_helper'

describe ::Composer::Json::JsonFile do

  subject(:json_file) { described_class }

  context '#parse_json' do

    [
      {
        name: 'detects extra comma',
        json: "{\n  \"foo\": \"bar\",\n}"
      },
      {
        name: 'detects extra comma in array',
        json: "{\n  \"foo\": [\n    \"bar\",\n  ]\n}"
      },
      {
        name: 'detects unescaped backslash',
        json: "{\n  \"fo\\o\": \"bar\",\n}"
      },
      {
        name: 'skips escaped backslash',
        json: "{\n  \"fo\\\\o\": \"bar\"\n  \"a\": \"b\"\n}"
      },
      {
        name: 'detects single quotes',
        json: "{\n  'foo': \"bar\"\n}"
      },
      {
        name: 'detects missing quotes',
        json: "{\n  foo: \"bar\"\n}"
      },
      {
        name: 'detects array as hash',
        json: "{\n  foo: [\"bar\": \"baz\"]\n}"
      },
      {
        name: 'detects missing comma',
        json: "{\n  \"foo\": \"bar\"\n  \"bar\": \"foo\"\n}"
      },
      {
        name: 'detects missing comma multi-line',
        json: "{\n  \"foo\": \"bar\"\n\n  \"bar\": \"foo\"\n}"
      },
      {
        name: 'detects missing colon',
        json: "{\n  \"foo\": \"bar\",\n  \"bar\" \"foo\"\n}"
      },

    ].each do |test|
      it "raises error when it #{test[:name]}" do
        expect { described_class::parse_json(test[:json]) }.to raise_error(::JSON::ParserError)
      end
    end

  end

  context '#encode' do

    [
      {
        name: 'simple json string',
        data: { 'name' => 'composer/composer' },
        expected: "{\n    \"name\": \"composer/composer\"\n}"
      },
      {
        name: 'trailing backslash',
        data: { 'Metadata\\' => 'src/' },
        expected: "{\n    \"Metadata\\\\\": \"src/\"\n}"
      },
      {
        name: 'empty array',
        data: { 'test' => [], 'test2' => {} },
        expected: "{\n    \"test\": [],\n    \"test2\": {}\n}"
      },
      {
        name: 'escape',
        data: { "Metadata\\\"" => 'src/' },
        expected: "{\n    \"Metadata\\\\\\\"\": \"src/\"\n}"
      },
      {
        name: 'unicode',
        data: { "Žluťoučký \" kůň" => "úpěl ďábelské ódy za €" },
        expected: "{\n    \"Žluťoučký \\\" kůň\": \"úpěl ďábelské ódy za €\"\n}"
      },
      {
        name: 'only unicode',
        data: %{\\/ƌ},
        options: described_class::JSON_UNESCAPED_UNICODE,
        expected: %{"\\\\/ƌ"}
      },
      {
        name: 'escaped slashes',
        data: %{\\/foo},
        options: 0,
        expected: %{"\\\\/foo"}
      },
      {
        name: 'escaped backslashes',
        data: %{a\\b},
        options: 0,
        expected: %{"a\\\\b"}
      },
      {
        name: 'escaped unicode',
        data: 'ƌ',
        options: 0,
        expected: %{"\u018c"}
      },

    ].each do |test|
      it "succeeds on #{test[:name]}" do
        if test[:options]
          expect(described_class::encode(test[:data], test[:options])).to be == test[:expected]
        else
          expect(described_class::encode(test[:data])).to be == test[:expected]
        end
      end
    end

    it 'succeeds on double escaped unicode' do
      data = ["Zdjęcia","hjkjhl\u0119kkjk"]
      encoded_data = described_class::encode(data)
      double_encoded_data = described_class::encode({ 't' => encoded_data })
      decoded_data = JSON::parse(double_encoded_data)
      double_data = JSON::parse(decoded_data['t'])
      expect(double_data).to be == data
    end

  end

  context '#write' do
    it 'succeeds' do
      data = { "test" => "test" }
      jsonFile = described_class.new(
        File.expand_path('../../../../fixtures/test.json', __FILE__)
      )
      jsonFile.write(data)
    end
  end

  context '#read' do
    it 'succeeds' do
      data = { "test" => "test" }
      jsonFile = described_class.new(
        File.expand_path('../../../../fixtures/test.json', __FILE__)
      )
      read_data = jsonFile.read
      expect(read_data).to be == data
    end
  end

  context '#validate_schema' do

    it 'returns true on valid schema' do
      json = described_class.new(
        File.expand_path('../../../../fixtures/composer.json', __FILE__)
      )
      expect(json.validate_schema).to be_truthy
    end

    it 'raises error on invalid schema' do
      json = described_class.new(
        File.expand_path('../../../../fixtures/test.json', __FILE__)
      )
      expect{ json.validate_schema }.to raise_error(::Composer::Json::JsonValidationError)
    end

  end

end
