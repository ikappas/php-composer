require_relative '../../../../spec_helper'

describe Composer::Package::LinkConstraint::MultiConstraint do

  VersionConstraint = Composer::Package::LinkConstraint::VersionConstraint
  MultiConstraint = Composer::Package::LinkConstraint::MultiConstraint

  it '#matches succeeds matching multi version' do
    version_require_start = VersionConstraint.new('>', '1.0')
    version_require_end = VersionConstraint.new('<', '1.2')
    version_provide = VersionConstraint.new('==', '1.1')

    multi_require = MultiConstraint.new([version_require_start, version_require_end])
    expect(multi_require.matches(version_provide)).to be_truthy
  end

  it '#matches succeeds matching multi version provided' do
    version_require_start = VersionConstraint.new('>', '1.0')
    version_require_end = VersionConstraint.new('<', '1.2')
    version_provide_start = VersionConstraint.new('>=', '1.1')
    version_provide_end = VersionConstraint.new('<', '2.0')

    multi_require = MultiConstraint.new([version_require_start, version_require_end])
    multi_provide = MultiConstraint.new([version_provide_start, version_provide_end])
    expect(multi_require.matches(multi_provide)).to be_truthy
  end

  it '#matches fails matching multi version' do
    version_require_start = VersionConstraint.new('>', '1.0')
    version_require_end = VersionConstraint.new('<', '1.2')
    version_provide = VersionConstraint.new('==', '1.2')

    multi_require = MultiConstraint.new([version_require_start, version_require_end])
    expect(multi_require.matches(version_provide)).to be_falsey
  end
end