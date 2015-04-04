describe 'Composer Schema Validation' do

  it 'succeeds validating required properties' do
    json = '{ }'
    expected = [
      "The property '#/' did not contain a required property of 'name' in schema e0ef79c3-2bd3-5e83-9f65-ce244ea07b41#",
      "The property '#/' did not contain a required property of 'description' in schema e0ef79c3-2bd3-5e83-9f65-ce244ea07b41#"
    ]
    expect( check(json) ).to be == expected

    json = '{ "name": "vendor/package" }'
    expected = [
      "The property '#/' did not contain a required property of 'description' in schema e0ef79c3-2bd3-5e83-9f65-ce244ea07b41#"
    ]
    expect( check(json) ).to be == expected

    json = '{ "description": "generic description" }'
    expected = [
      "The property '#/' did not contain a required property of 'name' in schema e0ef79c3-2bd3-5e83-9f65-ce244ea07b41#"
    ]
    expect( check(json) ).to be == expected
  end

  it 'succeeds validating minimum stability values' do
    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "" }'
    expected = [
      "The property '#/minimum-stability' value \"\" did not match the regex '^dev|alpha|beta|rc|RC|stable$' in schema e0ef79c3-2bd3-5e83-9f65-ce244ea07b41#"
    ]
    expect( check(json) ).to be == expected

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "dummy" }'
    expected = [
      "The property '#/minimum-stability' value \"dummy\" did not match the regex '^dev|alpha|beta|rc|RC|stable$' in schema e0ef79c3-2bd3-5e83-9f65-ce244ea07b41#"
    ]
    expect( check(json) ).to be == expected

    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "dev" }'
    expect(check(json)).to be_truthy, 'dev'
    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "alpha" }'
    expect(check(json)).to be_truthy, 'alpha'
    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "beta" }'
    expect(check(json)).to be_truthy, 'beta'
    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "rc" }'
    expect(check(json)).to be_truthy, 'rc lowercase'
    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "RC" }'
    expect(check(json)).to be_truthy, 'rc uppercase'
    json = '{ "name": "vendor/package", "description": "generic description", "minimum-stability": "stable" }'
    expect(check(json)).to be_truthy, 'stable'
  end

  def check(json)
    schema_file = File.join(File.dirname(__FILE__), '../../../../resources/composer-schema.json')
    schema_data = JSON.parse(
        File.open(schema_file, 'r') { |f| f.read }
    )
    if errors = JSON::Validator.fully_validate(schema_data, json)
      return errors
    end
    true
  end

end
