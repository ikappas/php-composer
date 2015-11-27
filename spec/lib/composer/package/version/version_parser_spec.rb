require_relative '../../../../spec_helper'

describe VersionParser do

  it 'format version for dev package' do
    [
      {
        source_reference: 'v2.1.0-RC2',
        truncate: true,
        expected: 'PrettyVersion v2.1.0-RC2'
      },
      {
        source_reference: 'bbf527a27356414bfa9bf520f018c5cb7af67c77',
        truncate: true,
        expected: 'PrettyVersion bbf527a'
      },
      {
        source_reference: 'v1.0.0',
        truncate: false,
        expected: 'PrettyVersion v1.0.0'
      },
      {
        source_reference: 'bbf527a27356414bfa9bf520f018c5cb7af67c77',
        truncate: false,
        expected: 'PrettyVersion bbf527a27356414bfa9bf520f018c5cb7af67c77'
      }
    ].each do |setup|
      package = double('Composer::Package::Package')
      expect(package).to receive('is_dev').once { true }
      expect(package).to receive('source_type').at_least(:once) { 'git' }
      expect(package).to receive('pretty_version').once { 'PrettyVersion' }
      expect(package).to receive('source_reference').at_least(:once) { setup[:source_reference] }

      formatted_version = VersionParser.format_version(package, setup[:truncate])
      expect(formatted_version).to be == setup[:expected]
    end
  end

  it '#parse_numeric_alias_prefix succeeds' do
    [
      { input: '0.x-dev',     expected: '0.' },
      { input: '1.0.x-dev',   expected: '1.0.' },
      { input: '1.x-dev',     expected: '1.' },
      { input: '1.2.x-dev',   expected: '1.2.' },
      { input: '1.2-dev',     expected: '1.2.' },
      { input: '1-dev',       expected: '1.' },
      { input: 'dev-develop', expected: false },
      { input: 'dev-master',  expected: false }
    ].each do |setup|
      parser = VersionParser.new
      expect(parser.parse_numeric_alias_prefix(setup[:input])).to be == setup[:expected]
    end
  end

  it '#normalize succeeds' do
    {
      'none'               => { input: '1.0.0',               expected: '1.0.0.0' },
      'none/2'             => { input: '1.2.3.4',             expected: '1.2.3.4' },
      'parses state'       => { input: '1.0.0RC1dev',         expected: '1.0.0.0-RC1-dev' },
      'CI parsing'         => { input: '1.0.0-rC15-dev',      expected: '1.0.0.0-RC15-dev' },
      'delimiters'         => { input: '1.0.0.RC.15-dev',     expected: '1.0.0.0-RC15-dev' },
      'RC uppercase'       => { input: '1.0.0-rc1',           expected: '1.0.0.0-RC1' },
      'patch replace'      => { input: '1.0.0.pl3-dev',       expected: '1.0.0.0-patch3-dev' },
      'forces w.x.y.z'     => { input: '1.0-dev',             expected: '1.0.0.0-dev' },
      'forces w.x.y.z/2'   => { input: '0',                   expected: '0.0.0.0' },
      'parses long'        => { input: '10.4.13-beta',        expected: '10.4.13.0-beta' },
      'parses long/2'      => { input: '10.4.13beta2',        expected: '10.4.13.0-beta2' },
      'parses long/semver' => { input: '10.4.13beta.2',       expected: '10.4.13.0-beta2' },
      'expand shorthand'   => { input: '10.4.13-b',           expected: '10.4.13.0-beta' },
      'expand shorthand2'  => { input: '10.4.13-b5',          expected: '10.4.13.0-beta5' },
      'strips leading v'   => { input: 'v1.0.0',              expected: '1.0.0.0' },
      'strips v/datetime'  => { input: 'v20100102',           expected: '20100102' },
      'parses dates y-m'   => { input: '2010.01',             expected: '2010-01' },
      'parses dates w/ .'  => { input: '2010.01.02',          expected: '2010-01-02' },
      'parses dates w/ -'  => { input: '2010-01-02',          expected: '2010-01-02' },
      'parses numbers'     => { input: '2010-01-02.5',        expected: '2010-01-02-5' },
      'parses dates y.m.Y' => { input: '2010.1.555',          expected: '2010.1.555.0' },
      'parses datetime'    => { input: '20100102-203040',     expected: '20100102-203040' },
      'parses dt+number'   => { input: '20100102203040-10',   expected: '20100102203040-10' },
      'parses dt+patch'    => { input: '20100102-203040-p1',  expected: '20100102-203040-patch1' },
      'parses master'      => { input: 'dev-master',          expected: '9999999-dev' },
      'parses trunk'       => { input: 'dev-trunk',           expected: '9999999-dev' },
      'parses branches'    => { input: '1.x-dev',             expected: '1.9999999.9999999.9999999-dev' },
      'parses arbitrary'   => { input: 'dev-feature-foo',     expected: 'dev-feature-foo' },
      'parses arbitrary2'  => { input: 'DEV-FOOBAR',          expected: 'dev-FOOBAR' },
      'parses arbitrary3'  => { input: 'dev-feature/foo',     expected: 'dev-feature/foo' },
      'ignores aliases'    => { input: 'dev-master as 1.0.0', expected: '9999999-dev' },
      'semver metadata'    => { input: 'dev-master+foo.bar',  expected: '9999999-dev' },
      'semver metadata/2'  => { input: '1.0.0-beta.5+foo',    expected: '1.0.0.0-beta5' },
      'semver metadata/3'  => { input: '1.0.0+foo',           expected: '1.0.0.0' },
      'metadata w/ alias'  => { input: '1.0.0+foo as 2.0',    expected: '1.0.0.0' }
    }.values.each do |setup|
      parser = Composer::Package::Version::VersionParser.new
      expect(parser.normalize(setup[:input])).to be == setup[:expected]
    end
  end

  it '#normalize fails' do
    {
      'nil'               => { input: nil, error: Composer::ArgumentError },
      'empty '            => { input: '', error: Composer::UnexpectedValueError },
      'invalid chars'     => { input: 'a', error: Composer::UnexpectedValueError },
      'invalid type'      => { input: '1.0.0-meh', error: Composer::UnexpectedValueError },
      'too many bits'     => { input: '1.0.0.0.0', error: Composer::UnexpectedValueError },
      'non-dev arbitrary' => { input: 'feature-foo', error: Composer::UnexpectedValueError },
      'metadata w/ space' => { input: '1.0.0+foo bar', error: Composer::UnexpectedValueError }
    }.values.each do |setup|
      parser = Composer::Package::Version::VersionParser.new
      expect { parser.normalize(setup[:input]) }.to raise_error(setup[:error])
    end
  end

  it '#normalize_stability succeeds' do
    [
      { stability: 'STABLE', expected: 'stable' },
      { stability: 'stable', expected: 'stable' },
      { stability: 'RC', expected: 'RC' },
      { stability: 'rc', expected: 'RC' },
      { stability: 'BETA', expected: 'beta' },
      { stability: 'beta', expected: 'beta' },
      { stability: 'ALPHA', expected: 'alpha' },
      { stability: 'alpha', expected: 'alpha' },
      { stability: 'DEV', expected: 'dev' },
      { stability: 'dev',   expected: 'dev' },
    ].each do |setup|
      expect(VersionParser.normalize_stability(setup[:stability])).to be == setup[:expected]
    end
  end

  it '#normalize_stability fails' do
    {
      'nil'   => { stability: nil,      error: Composer::ArgumentError },
      'array' => { stability: ['test'], error: Composer::TypeError },
    }.values.each do |setup|
      expect { VersionParser.normalize_stability(setup[:stability]) }.to raise_error(setup[:error])
    end
  end

  it '#normalize_branch succeeds' do
    {
      'parses x'              => { input: 'v1.x',        expected: '1.9999999.9999999.9999999-dev' },
      'parses *'              => { input: 'v1.*',        expected: '1.9999999.9999999.9999999-dev' },
      'parses digits'         => { input: 'v1.0',        expected: '1.0.9999999.9999999-dev' },
      'parses digits/2'       => { input: '2.0',         expected: '2.0.9999999.9999999-dev' },
      'parses long x'         => { input: 'v1.0.x',      expected: '1.0.9999999.9999999-dev' },
      'parses long *'         => { input: 'v1.0.3.*',    expected: '1.0.3.9999999-dev' },
      'parses long digits'    => { input: 'v2.4.0',      expected: '2.4.0.9999999-dev' },
      'parses long digits/2'  => { input: '2.4.4',       expected: '2.4.4.9999999-dev' },
      'parses master'         => { input: 'master',      expected: '9999999-dev' },
      'parses trunk'          => { input: 'trunk',       expected: '9999999-dev' },
      'parses arbitrary'      => { input: 'feature-a',   expected: 'dev-feature-a' },
      'parses arbitrary/2'    => { input: 'FOOBAR',      expected: 'dev-FOOBAR' }
    }.values.each do |setup|
      parser = Composer::Package::Version::VersionParser.new
      expect(parser.normalize_branch(setup[:input])).to be == setup[:expected]
    end
  end

  it '#parse_constraints ignores stability flag' do
    parser = VersionParser.new
    constraint = VersionConstraint.new('=', '1.0.0.0')
    expect( String(parser.parse_constraints('1.0@dev')) ).to be == String(constraint)
  end

  it '#parse_constraints ignores reference on dev version' do
    parser = VersionParser.new
    constraint = VersionConstraint.new('=', '1.0.9999999.9999999-dev')
    expect( String(parser.parse_constraints('1.0.x-dev#abcd123')) ).to be == String(constraint)
    expect( String(parser.parse_constraints('1.0.x-dev#trunk/@123')) ).to be == String(constraint)
  end

  it '#parse_constraints fails on bad reference' do
    parser = VersionParser.new
    expect { String(parser.parse_constraints('1.0#abcd123')) }.to raise_error(Composer::UnexpectedValueError)
    expect { String(parser.parse_constraints('1.0#trunk/@123')) }.to raise_error(Composer::UnexpectedValueError)
    expect { String(parser.parse_constraints('1.0@123')) }.to raise_error(Composer::UnexpectedValueError)
  end

  it '#parse_constraints nudges ruby devs towards the path of righteousness' do
    parser = VersionParser.new
    expect { String(parser.parse_constraints('~>1.2')) }.to raise_error(Composer::UnexpectedValueError)
  end

  it '#parse_constraints succeeds parsing simple' do
    {
      'match any'             => { input: '*',                    constraint: EmptyConstraint.new },
      'match any/2'           => { input: '*.*',                  constraint: EmptyConstraint.new },
      'match any/3'           => { input: '*.x.*',                constraint: EmptyConstraint.new },
      'match any/4'           => { input: 'x.X.x.*',              constraint: EmptyConstraint.new },
      'not equal'             => { input: '<>1.0.0',              constraint: VersionConstraint.new('<>', '1.0.0.0') },
      'not equal/2'           => { input: '!=1.0.0',              constraint: VersionConstraint.new('!=', '1.0.0.0') },
      'greater than'          => { input: '>1.0.0',               constraint: VersionConstraint.new('>', '1.0.0.0') },
      'lesser than'           => { input: '<1.2.3.4',             constraint: VersionConstraint.new('<', '1.2.3.4-dev') },
      'less/eq than'          => { input: '<=1.2.3',              constraint: VersionConstraint.new('<=', '1.2.3.0') },
      'great/eq than'         => { input: '>=1.2.3',              constraint: VersionConstraint.new('>=', '1.2.3.0') },
      'equals'                => { input: '=1.2.3',               constraint: VersionConstraint.new('=', '1.2.3.0') },
      'double equals'         => { input: '==1.2.3',              constraint: VersionConstraint.new('=', '1.2.3.0') },
      'no op means eq'        => { input: '1.2.3',                constraint: VersionConstraint.new('=', '1.2.3.0') },
      'completes version'     => { input: '=1.0',                 constraint: VersionConstraint.new('=', '1.0.0.0') },
      'shorthand beta'        => { input: '1.2.3b5',              constraint: VersionConstraint.new('=', '1.2.3.0-beta5') },
      'accepts spaces'        => { input: '>= 1.2.3',             constraint: VersionConstraint.new('>=', '1.2.3.0') },
      'accepts spaces/2'      => { input: '< 1.2.3',              constraint: VersionConstraint.new('<', '1.2.3.0-dev') },
      'accepts spaces/3'      => { input: '> 1.2.3',              constraint: VersionConstraint.new('>', '1.2.3.0') },
      'accepts master'        => { input: '>=dev-master',         constraint: VersionConstraint.new('>=', '9999999-dev') },
      'accepts master/2'      => { input: 'dev-master',           constraint: VersionConstraint.new('=', '9999999-dev') },
      'accepts arbitrary'     => { input: 'dev-feature-a',        constraint: VersionConstraint.new('=', 'dev-feature-a') },
      'regression #550'       => { input: 'dev-some-fix',         constraint: VersionConstraint.new('=', 'dev-some-fix') },
      'regression #935'       => { input: 'dev-CAPS',             constraint: VersionConstraint.new('=', 'dev-CAPS') },
      'ignores aliases'       => { input: 'dev-master as 1.0.0',  constraint: VersionConstraint.new('=', '9999999-dev') },
      'lesser than override'  => { input: '<1.2.3.4-stable',      constraint: VersionConstraint.new('<', '1.2.3.4') }
    }.values.each do |setup|
        parser = VersionParser.new
        expect( String(parser.parse_constraints(setup[:input])) ).to be == String(setup[:constraint])
    end
  end

  it '#parse_constraints succeeds parsing wildcards' do
    [
      { input: '2.*',     min: VersionConstraint.new('>=', '2.0.0.0-dev'),  max: VersionConstraint.new('<', '3.0.0.0-dev') },
      { input: '20.*',    min: VersionConstraint.new('>=', '20.0.0.0-dev'), max: VersionConstraint.new('<', '21.0.0.0-dev') },
      { input: '2.0.*',   min: VersionConstraint.new('>=', '2.0.0.0-dev'),  max: VersionConstraint.new('<', '2.1.0.0-dev') },
      { input: '2.2.x',   min: VersionConstraint.new('>=', '2.2.0.0-dev'),  max: VersionConstraint.new('<', '2.3.0.0-dev') },
      { input: '2.10.X',  min: VersionConstraint.new('>=', '2.10.0.0-dev'), max: VersionConstraint.new('<', '2.11.0.0-dev') },
      { input: '2.1.3.*', min: VersionConstraint.new('>=', '2.1.3.0-dev'),  max: VersionConstraint.new('<', '2.1.4.0-dev') },
      { input: '0.*',     min: nil,                                         max: VersionConstraint.new('<', '1.0.0.0-dev') }
    ].each do |setup|
      parser = VersionParser.new
      if setup[:min]
        expected = MultiConstraint.new([setup[:min], setup[:max]])
      else
        expected = setup[:max]
      end
      expect( String(parser.parse_constraints(setup[:input])) ).to be == String(expected)
    end
  end


  it '#parse_constraints succeeds parsing tilde wildcard' do
    [
      { input: '~1',            min: VersionConstraint.new('>=', '1.0.0.0-dev'),    max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '~1.0',          min: VersionConstraint.new('>=', '1.0.0.0-dev'),    max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '~1.0.0',        min: VersionConstraint.new('>=', '1.0.0.0-dev'),    max: VersionConstraint.new('<', '1.1.0.0-dev') },
      { input: '~1.2',          min: VersionConstraint.new('>=', '1.2.0.0-dev'),    max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '~1.2.3',        min: VersionConstraint.new('>=', '1.2.3.0-dev'),    max: VersionConstraint.new('<', '1.3.0.0-dev') },
      { input: '~1.2.3.4',      min: VersionConstraint.new('>=', '1.2.3.4-dev'),    max: VersionConstraint.new('<', '1.2.4.0-dev') },
      { input: '~1.2-beta',     min: VersionConstraint.new('>=', '1.2.0.0-beta'),   max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '~1.2-b2',       min: VersionConstraint.new('>=', '1.2.0.0-beta2'),  max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '~1.2-BETA2',    min: VersionConstraint.new('>=', '1.2.0.0-beta2'),  max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '~1.2.2-dev',    min: VersionConstraint.new('>=', '1.2.2.0-dev'),    max: VersionConstraint.new('<', '1.3.0.0-dev') },
      { input: '~1.2.2-stable', min: VersionConstraint.new('>=', '1.2.2.0-stable'), max: VersionConstraint.new('<', '1.3.0.0-dev') }
    ].each do |setup|
      parser = VersionParser.new
      if setup[:min]
        expected = MultiConstraint.new([setup[:min], setup[:max]])
      else
        expected = setup[:max]
      end
      expect( String(parser.parse_constraints(setup[:input])) ).to be == String(expected)
    end
  end

  it '#parse_constraints succeeds parsing caret wildcard' do
    [
      { input: '^1',            min: VersionConstraint.new('>=', '1.0.0.0-dev'),   max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '^0',            min: VersionConstraint.new('>=', '0.0.0.0-dev'),   max: VersionConstraint.new('<', '1.0.0.0-dev') },
      { input: '^0.0',          min: VersionConstraint.new('>=', '0.0.0.0-dev'),   max: VersionConstraint.new('<', '0.1.0.0-dev') },
      { input: '^1.2',          min: VersionConstraint.new('>=', '1.2.0.0-dev'),   max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '^1.2.3-beta.2', min: VersionConstraint.new('>=', '1.2.3.0-beta2'), max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '^1.2.3.4',      min: VersionConstraint.new('>=', '1.2.3.4-dev'),   max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '^1.2.3',        min: VersionConstraint.new('>=', '1.2.3.0-dev'),   max: VersionConstraint.new('<', '2.0.0.0-dev') },
      { input: '^0.2.3',        min: VersionConstraint.new('>=', '0.2.3.0-dev'),   max: VersionConstraint.new('<', '0.3.0.0-dev') },
      { input: '^0.2',          min: VersionConstraint.new('>=', '0.2.0.0-dev'),   max: VersionConstraint.new('<', '0.3.0.0-dev') },
      { input: '^0.0.3',        min: VersionConstraint.new('>=', '0.0.3.0-dev'),   max: VersionConstraint.new('<', '0.0.4.0-dev') },
      { input: '^0.0.3-alpha',  min: VersionConstraint.new('>=', '0.0.3.0-alpha'), max: VersionConstraint.new('<', '0.0.4.0-dev') },
      { input: '^0.0.3-dev',    min: VersionConstraint.new('>=', '0.0.3.0-dev'),   max: VersionConstraint.new('<', '0.0.4.0-dev') }
    ].each do |setup|
      parser = VersionParser.new
      if setup[:min]
        expected = MultiConstraint.new([setup[:min], setup[:max]])
      else
        expected = setup[:max]
      end
      expect( String(parser.parse_constraints(setup[:input])) ).to be == String(expected)
    end
  end

  it '#parse_constraints succeeds parsing hyphen' do
    [
      { input: '1 - 2',                min: VersionConstraint.new('>=', '1.0.0.0-dev'),   max: VersionConstraint.new('<',  '3.0.0.0-dev') },
      { input: '1.2.3 - 2.3.4.5',      min: VersionConstraint.new('>=', '1.2.3.0-dev'),   max: VersionConstraint.new('<=', '2.3.4.5') },
      { input: '1.2-beta - 2.3',       min: VersionConstraint.new('>=', '1.2.0.0-beta'),  max: VersionConstraint.new('<',  '2.4.0.0-dev') },
      { input: '1.2-beta - 2.3-dev',   min: VersionConstraint.new('>=', '1.2.0.0-beta'),  max: VersionConstraint.new('<=', '2.3.0.0-dev') },
      { input: '1.2-RC - 2.3.1',       min: VersionConstraint.new('>=', '1.2.0.0-RC'),    max: VersionConstraint.new('<=', '2.3.1.0') },
      { input: '1.2.3-alpha - 2.3-RC', min: VersionConstraint.new('>=', '1.2.3.0-alpha'), max: VersionConstraint.new('<=', '2.3.0.0-RC') }
    ].each do |setup|
      parser = VersionParser.new
      if setup[:min]
        expected = MultiConstraint.new([setup[:min], setup[:max]])
      else
        expected = setup[:max]
      end
      expect( String(parser.parse_constraints(setup[:input])) ).to be == String(expected)
    end
  end

  it '#parse_constraints succeeds parsing multi constraints' do
    [
      { constraint: '>2.0,<=3.0' },
      { constraint: '>2.0 <=3.0' },
      { constraint: '>2.0  <=3.0' },
      { constraint: '>2.0, <=3.0' },
      { constraint: '>2.0 ,<=3.0' },
      { constraint: '>2.0 , <=3.0' },
      { constraint: '>2.0   , <=3.0' },
      { constraint: '> 2.0   <=  3.0' },
      { constraint: '> 2.0  ,  <=  3.0' },
      { constraint: '  > 2.0  ,  <=  3.0 ' }
    ].each do |setup|
      parser = VersionParser.new
      first = VersionConstraint.new('>', '2.0.0.0')
      second = VersionConstraint.new('<=', '3.0.0.0')
      multi = MultiConstraint.new([first, second])
      expect( String(parser.parse_constraints(setup[:constraint])) ).to be == String(multi)
    end
  end

  it '#parse_constraints succeeds parsing multi constraints with stability suffix' do
    parser = VersionParser.new

    first = VersionConstraint.new('>=', '1.1.0.0-alpha4')
    second = VersionConstraint.new('<', '1.2.9999999.9999999-dev')
    multi = MultiConstraint.new([first, second])
    expect( String(parser.parse_constraints('>=1.1.0-alpha4,<1.2.x-dev')) ).to be == String(multi)

    first = VersionConstraint.new('>=', '1.1.0.0-alpha4')
    second = VersionConstraint.new('<', '1.2.0.0-beta2')
    multi = MultiConstraint.new([first, second])
    expect( String(parser.parse_constraints('>=1.1.0-alpha4,<1.2-beta2')) ).to be == String(multi)
  end

  it '#parse_constraints succeeds parsing multi disjunctive has prio over conjuctive' do
    [
      { constraint: '>2.0,<2.0.5 | >2.0.6' },
      { constraint: '>2.0,<2.0.5 || >2.0.6' },
      { constraint: '> 2.0 , <2.0.5 | >  2.0.6' }
    ].each do |setup|
      parser = VersionParser.new
      first = VersionConstraint.new('>', '2.0.0.0')
      second = VersionConstraint.new('<', '2.0.5.0-dev')
      third = VersionConstraint.new('>', '2.0.6.0')
      multi1 = MultiConstraint.new([first, second])
      multi2 = MultiConstraint.new([multi1, third], false)
      expect( String(parser.parse_constraints(setup[:constraint])) ).to be == String(multi2)
    end
  end

  it '#parse_constraints succeeds parsing multi with stabilities' do
    parser = VersionParser.new
    first = VersionConstraint.new('>', '2.0.0.0')
    second = VersionConstraint.new('<=', '3.0.0.0-dev')
    multi = MultiConstraint.new([first, second])
    expect( String(parser.parse_constraints('>2.0@stable,<=3.0@dev')) ).to be == String(multi)
  end

  it '#parse_constraints fails' do
    {
      'nil'               => { input: nil, error: Composer::ArgumentError },
      'empty'             => { input: '', error: Composer::UnexpectedValueError },
      'invalid version'   => { input: '1.0.0-meh', error: Composer::UnexpectedValueError },
      'operator abuse'    => { input: '>2.0,,<=3.0', error: Composer::UnexpectedValueError },
      'operator abuse/2'  => { input: '>2.0 ,, <=3.0', error: Composer::UnexpectedValueError },
      'operator abuse/3'  => { input: '>2.0 ||| <=3.0', error: Composer::UnexpectedValueError }
    }.values.each do |setup|
      parser = VersionParser.new
      expect { parser.parse_constraints(setup[:input]) }.to raise_error(setup[:error])
    end
  end

  it '#parse_stability succeeds' do
    [
      { expected: 'stable', version: '1' },
      { expected: 'stable', version: '1.0' },
      { expected: 'stable', version: '3.2.1' },
      { expected: 'stable', version: 'v3.2.1' },
      { expected: 'dev',    version: 'v2.0.x-dev' },
      { expected: 'dev',    version: 'v2.0.x-dev#abc123' },
      { expected: 'dev',    version: 'v2.0.x-dev#trunk/@123' },
      { expected: 'RC',     version: '3.0-RC2' },
      { expected: 'dev',    version: 'dev-master' },
      { expected: 'dev',    version: '3.1.2-dev' },
      { expected: 'stable', version: '3.1.2-pl2' },
      { expected: 'stable', version: '3.1.2-patch' },
      { expected: 'alpha',  version: '3.1.2-alpha5' },
      { expected: 'beta',   version: '3.1.2-beta' },
      { expected: 'beta',   version: '2.0B1' },
      { expected: 'alpha',  version: '1.2.0a1' },
      { expected: 'alpha',  version: '1.2_a1' },
      { expected: 'RC',     version: '2.0.0rc1' }
    ].each do |setup|
      expect( VersionParser.parse_stability(setup[:version]) ).to be == setup[:expected]
    end
  end

  it '#parse_stability fails' do
    {
      'nil'   => { version: nil,      error: Composer::ArgumentError },
      'array' => { version: ['test'], error: Composer::TypeError },
      'empty' => { version: '',       error: Composer::UnexpectedValueError },
    }.values.each do |setup|
      expect { VersionParser.parse_stability(setup[:version]) }.to raise_error(setup[:error])
    end
  end

end
