describe Composer::Json::JsonFormatter do

  JsonFormatter = Composer::Json::JsonFormatter

  it '#format succeeds on pretty printing' do
    data = '{"key":"value","array":[],"hash":{}}'
    options = JsonFormatter::JSON_PRETTY_PRINT
    expected = "{\n    \"key\": \"value\",\n    \"array\": [],\n    \"hash\": {}\n}"
    expect( JsonFormatter::format(data, options) ).to be == expected
  end

  it '#format succeeds on hex tags' do
    data = '{"html":"<html><body></body></html>"}'
    options = JsonFormatter::JSON_HEX_TAG
    expected = "{\"html\":\"\\u003Chtml\\u003E\\u003Cbody\\u003E\\u003C/body\\u003E\\u003C/html\\u003E\"}"
    formatted = JsonFormatter::format(data, options)
    expect( formatted ).to be == expected
    expect( JSON::parse(formatted) ).to be == JSON::parse(data)
  end

  it '#format succeeds on hex ampersand' do
    data = '{"color":"&FFFFFF"}'
    options = JsonFormatter::JSON_HEX_AMP
    expected = "{\"color\":\"\\u0026FFFFFF\"}"
    formatted = JsonFormatter::format(data, options)
    expect( formatted ).to be == expected
    expect( JSON::parse(formatted) ).to be == JSON::parse(data)
  end

  it '#format succeeds on double hex ampersand' do
    data = '{"color":"&&FFFFFF"}'
    options = JsonFormatter::JSON_HEX_AMP
    expected = "{\"color\":\"\\u0026\\u0026FFFFFF\"}"
    formatted = JsonFormatter::format(data, options)
    expect( formatted ).to be == expected
    expect( JSON::parse(formatted) ).to be == JSON::parse(data)
  end

  it '#format succeeds on hex apostrophe' do
    data = '["John\'s Package"]'
    options = JsonFormatter::JSON_HEX_APOS
    expected = "[\"John\\u0027s Package\"]"
    formatted = JsonFormatter::format(data, options)
    expect( formatted ).to be == expected
    expect( JSON::parse(formatted) ).to be == JSON::parse(data)
  end

  it '#format succeeds on hex quote' do
    data = '{"quote": "This is a \"test\""}'
    options = JsonFormatter::JSON_HEX_QUOT
    expected = "{\"quote\": \"This is a \\u0022test\\u0022\"}"
    formatted = JsonFormatter::format(data, options)
    expect( formatted ).to be == expected
    expect( JSON::parse(formatted) ).to be == JSON::parse(data)
  end

  it '#format succeeds on unicode with prepended slash' do
    data = '"' + 92.chr + 92.chr + 92.chr + 'u0119"'
    options = JsonFormatter::JSON_UNESCAPED_SLASHES && JsonFormatter::JSON_UNESCAPED_UNICODE
    encoded_data = JsonFormatter::format(data, options)
    expected = '34+92+92+196+153+34'
    expect( encoded_data.bytes.join('+') ).to be == expected
  end

end