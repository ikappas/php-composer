require_relative '../../../spec_helper'
require 'json-schema'

describe 'Composer Schema Validation' do

  let(:schema_file){ File.realpath(File.join(File.dirname(__FILE__), '../../../../resources/composer-schema.json' )) }
  let(:schema_uri) { 'file://' + schema_file }

  it 'succeeds validating required properties' do
    json = '{ }'
    expected = [
      "The property '#/' did not contain a required property of 'name' in schema #{schema_uri}#",
      "The property '#/' did not contain a required property of 'description' in schema #{schema_uri}#"
    ]
    expect( validate(schema_file, json) ).to be == expected

    json = '{ "name": "vendor/package" }'
    expected = [
      "The property '#/' did not contain a required property of 'description' in schema #{schema_uri}#"
    ]
    expect( validate(schema_file, json) ).to be == expected

    json = '{ "description": "generic description" }'
    expected = [
      "The property '#/' did not contain a required property of 'name' in schema #{schema_uri}#"
    ]
    expect( validate(schema_file, json) ).to be == expected
  end

  it 'succeeds validating minimum stability values' do
    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "" }'
    expected = [
      "The property '#/minimum-stability' value \"\" did not match the regex '^dev|alpha|beta|rc|RC|stable$' in schema #{schema_uri}#"
    ]
    expect( validate(schema_file, json) ).to be == expected

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "dummy" }'
    expected = [
      "The property '#/minimum-stability' value \"dummy\" did not match the regex '^dev|alpha|beta|rc|RC|stable$' in schema #{schema_uri}#"
    ]
    expect( validate(schema_file, json) ).to be == expected

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "dev" }'
    expect( validate(schema_file, json) ).to be_truthy, 'dev'

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "alpha" }'
    expect( validate(schema_file, json) ).to be_truthy, 'alpha'

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "beta" }'
    expect( validate(schema_file, json) ).to be_truthy, 'beta'

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "rc" }'
    expect( validate(schema_file, json) ).to be_truthy, 'rc lowercase'

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "RC" }'
    expect( validate(schema_file, json) ).to be_truthy, 'rc uppercase'

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "stable" }'
    expect( validate(schema_file, json) ).to be_truthy, 'stable'
  end

  def validate(schema_file, json)
    validator = JSON::Validator.new(schema_file, json, record_errors: true, json: true)
    errors = validator.validate
    errors.nil? ? true : errors
  end

end
