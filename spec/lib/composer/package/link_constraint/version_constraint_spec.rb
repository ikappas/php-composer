require_relative '../../../../spec_helper'

describe VersionConstraint do

  it '#matches returns true' do
    [
      { r: { operator: '==', version:'1' }, p: { operator: '==', version: '1' } },
      { r: { operator: '>=', version:'1' }, p: { operator: '>=', version: '2' } },
      { r: { operator: '>=', version:'2' }, p: { operator: '>=', version: '1' } },
      { r: { operator: '>=', version:'2' }, p: { operator: '>',  version: '1' } },
      { r: { operator: '<=', version:'2' }, p: { operator: '>=', version: '1' } },
      { r: { operator: '>=', version:'1' }, p: { operator: '<=', version: '2' } },
      { r: { operator: '==', version:'2' }, p: { operator: '>=', version: '2' } },
      { r: { operator: '!=', version:'1' }, p: { operator: '!=', version: '1' } },
      { r: { operator: '!=', version:'1' }, p: { operator: '==', version: '2' } },
      { r: { operator: '!=', version:'1' }, p: { operator: '<',  version: '1' } },
      { r: { operator: '!=', version:'1' }, p: { operator: '<=', version: '1' } },
      { r: { operator: '!=', version:'1' }, p: { operator: '>',  version: '1' } },
      { r: { operator: '!=', version:'1' }, p: { operator: '>=', version: '1' } },
      { r: { operator: '==', version:'dev-foo-bar' }, p: { operator: '==', version: 'dev-foo-bar' } },
      { r: { operator: '==', version:'dev-foo-xyz' }, p: { operator: '==', version: 'dev-foo-xyz' } },
      { r: { operator: '>=', version:'dev-foo-bar' }, p: { operator: '>=', version: 'dev-foo-xyz' } },
      { r: { operator: '<=', version:'dev-foo-bar' }, p: { operator: '<',  version: 'dev-foo-xyz' } },
      { r: { operator: '!=', version:'dev-foo-bar' }, p: { operator: '<',  version: 'dev-foo-xyz' } },
      { r: { operator: '>=', version:'dev-foo-bar' }, p: { operator: '!=', version: 'dev-foo-bar' } },
      { r: { operator: '!=', version:'dev-foo-bar' }, p: { operator: '!=', version: 'dev-foo-xyz' } },
    ].each do |setup|
      version_require = VersionConstraint.new(setup[:r][:operator], setup[:r][:version])
      version_provide = VersionConstraint.new(setup[:p][:operator], setup[:p][:version]);
      expect(version_require.matches(version_provide)).to be_truthy
    end
  end

  it '#matches returns false' do
    [
      { r: { operator: '==', version: '1' }, p: { operator: '==', version: '2' } },
      { r: { operator: '>=', version: '2' }, p: { operator: '<=', version: '1' } },
      { r: { operator: '>=', version: '2' }, p: { operator: '<',  version: '2' } },
      { r: { operator: '<=', version: '2' }, p: { operator: '>',  version: '2' } },
      { r: { operator: '>',  version: '2' }, p: { operator: '<=', version: '2' } },
      { r: { operator: '<=', version: '1' }, p: { operator: '>=', version: '2' } },
      { r: { operator: '>=', version: '2' }, p: { operator: '<=', version: '1' } },
      { r: { operator: '==', version: '2' }, p: { operator: '<',  version: '2' } },
      { r: { operator: '!=', version: '1' }, p: { operator: '==', version: '1' } },
      { r: { operator: '==', version: '1' }, p: { operator: '!=', version: '1' } },
      { r: { operator: '==', version: 'dev-foo-dist' }, p: { operator: '==', version: 'dev-foo-zist' } },
      { r: { operator: '==', version: 'dev-foo-bist' }, p: { operator: '==', version: 'dev-foo-aist' } },
      { r: { operator: '<=', version: 'dev-foo-bist' }, p: { operator: '>=', version: 'dev-foo-aist' } },
      { r: { operator: '>=', version: 'dev-foo-bist' }, p: { operator: '<',  version: 'dev-foo-aist' } },
      { r: { operator: '<',  version: '0.12' }, p: { operator: '==', version: 'dev-foo' } }, # branches are not comparable
      { r: { operator: '>',  version: '0.12' }, p: { operator: '==', version: 'dev-foo' } } # branches are not comparable
    ].each do |setup|
      version_require = VersionConstraint.new(setup[:r][:operator], setup[:r][:version])
      version_provide = VersionConstraint.new(setup[:p][:operator], setup[:p][:version])
      expect(version_require.matches(version_provide)).to be_falsey
    end
  end

  it 'comparable branches' do

    version_require = VersionConstraint.new('>', '0.12')
    version_provide = VersionConstraint.new('==', 'dev-foo')

    expect(version_require.matches(version_provide)).to be_falsey
    expect(version_require.match_specific(version_provide, true)).to be_falsey

    version_require = VersionConstraint.new('<', '0.12')
    version_provide = VersionConstraint.new('==', 'dev-foo')

    expect(version_require.matches(version_provide)).to be_falsey
    expect(version_require.match_specific(version_provide, true)).to be_truthy

  end
end