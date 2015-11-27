require_relative '../../../spec_helper'

describe JsonFile do

  it 'parse error detect extra comma' do
    json = '{
        "foo": "bar",
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
  end

  it 'parse error detect extra comma in array' do
    json = '{
      "foo": [
        "bar",
      ]
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
  end

  # it 'parse error detect unescaped backslash' do
  #   json = '{
  #     "fo\o": "bar"
  #   }'
  #   expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
  # end

  it 'parse error skips escaped backslash' do
    json = '{
      "fo\\\\o": "bar"
      "a": "b"
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
    # JsonFileHelpers.expect_parse_exception("", json)
    # $this->expectParseException('Parse error on line 2', json)
  end

  it 'parse error detect single quotes' do
    json = '{
      \'foo\': "bar"
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
    # $this->expectParseException('Parse error on line 1', json)
  end

  it 'parse error detect missing quotes' do
    json = '{
      foo: "bar"
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
    # $this->expectParseException('Parse error on line 1', json)
  end

  it 'parse error detect array as hash' do
    json = '{
      "foo": ["bar": "baz"]
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
    # $this->expectParseException('Parse error on line 2', json)
  end

  it 'parse error detect missing comma' do
    json = '{
      "foo": "bar"
      "bar": "foo"
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
    # $this->expectParseException('Parse error on line 2', json)
  end

  it 'schema validation' do
    json = Composer::Json::JsonFile.new(
      File.expand_path("../../../../fixtures/composer.json", __FILE__)
    )
    expect(json.validate_schema).to be_truthy
  end

  it 'parse error detect missing comma multiline' do
    json = '{
      "foo": "barbar"

      "bar": "foo"
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
    # $this->expectParseException('Parse error on line 2', json)
  end

  it 'ParseErrorDetectMissingColon' do
    json = '{
      "foo": "bar",
      "bar" "foo"
    }'
    expect { JsonFile.parse_json(json) }.to raise_error(JSON::ParserError)
    # $this->expectParseException('Parse error on line 3', json)
  end

  it 'SimpleJsonString' do
    data = { 'name' => 'composer/composer' }
    json = "{\n    \"name\": \"composer/composer\"\n}"
    expect(JsonFile::encode(data)).to be == json
  end

  it 'TrailingBackslash' do
    data = { 'Metadata\\' => 'src/' }
    json = "{\n    \"Metadata\\\\\": \"src/\"\n}"
    expect(JsonFile::encode(data)).to be == json
  end

  it 'FormatEmptyArray' do
    data = { 'test' => [], 'test2' => {} }
    json = "{\n    \"test\": [],\n    \"test2\": {}\n}"
    expect(JsonFile::encode(data)).to be == json
  end

  it 'Escape' do
    data = { "Metadata\\\"" => 'src/' }
    json = "{\n    \"Metadata\\\\\\\"\": \"src/\"\n}"
    expect(JsonFile::encode(data)).to be == json
  end

  it 'Unicode' do
    data = { "Žluťoučký \" kůň" => "úpěl ďábelské ódy za €" }
    json = "{\n    \"Žluťoučký \\\" kůň\": \"úpěl ďábelské ódy za €\"\n}"
    expect(JsonFile::encode(data)).to be == json
  end

  it 'OnlyUnicode' do
    data = %{\\/ƌ}
    json = %{"\\\\/ƌ"}
    # $this->assertJsonFormat('"\\\\\\/ƌ"', data, JsonFile::JSON_UNESCAPED_UNICODE)
    options = JsonFormatter::JSON_UNESCAPED_UNICODE
    expect(JsonFile::encode(data, options)).to be == json
  end

  it 'EscapedSlashes' do
    data = %{\\/foo}
    json = %{"\\\\/foo"}
    options = 0
    expect(JsonFile::encode(data, options)).to be == json
    # $this->assertJsonFormat('"\\\\\\/foo"', data, 0)
  end

  it 'EscapedBackslashes' do
    data = %{a\\b}
    json = %{"a\\\\b"}
    options = 0
    expect(JsonFile::encode(data, options)).to be == json
    # $this->assertJsonFormat('"a\\\\b"', data, 0)
  end

  it 'EscapedUnicode' do
    data = 'ƌ'
    json = %{"\u018c"}
    options = 0
    expect(JsonFile::encode(data, options)).to be == json
    # $this->assertJsonFormat('"\\u018c"', data, 0)
  end

  it 'DoubleEscapedUnicode' do
    # jsonFile = new JsonFile('composer.json')
    data = ["Zdjęcia","hjkjhl\u0119kkjk"]
    encoded_data = JsonFile::encode(data)
    double_encoded_data = JsonFile.encode({ 't' => encoded_data })
    decoded_data = JSON::parse(double_encoded_data)
    double_data = JSON::parse(decoded_data['t'])
    expect(double_data).to be == data
  end

  it '#write succeeds' do
    data = { "test" => "test" }
    jsonFile = JsonFile.new(
        File.expand_path('../../../../fixtures/test.json', __FILE__)
    )
    jsonFile.write(data)
  end

  it '#read succeeds' do
    data = { "test" => "test" }
    jsonFile = JsonFile.new(
        File.expand_path('../../../../fixtures/test.json', __FILE__)
    )
    read_data = jsonFile.read
    expect(read_data).to be == data
  end
end
