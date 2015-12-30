require_relative '../../../spec_helper'

describe ::Composer::Package::Package do

  context '#repository' do

    let(:repository) do
      @repository ||= ::Composer::Repository::HashRepository.new
    end

    let(:package) do
      @package ||= begin
        pkg = described_class.new('foo', '1.0.0.0', '1.0')
        pkg.repository = repository
        pkg
      end
    end

    it 'sets same repository' do
      same_repository = repository
      expect { package.repository = same_repository }.not_to raise_error
    end

    it 'does not set other repository' do
      other_repository = ::Composer::Repository::HashRepository.new
      expect { package.repository = other_repository }.to raise_error(::Composer::LogicError)
    end

  end

  context '#full_pretty_version' do

    let(:package) do
      @package ||= described_class.new('foo', '1.0.0.0', '1.0')
    end

    [
        {
            source_reference: 'v2.1.0-RC2',
            truncate: true,
            expected: 'PrettyVersion v2.1.0-RC2',
        },
        {
            source_reference: 'bbf527a27356414bfa9bf520f018c5cb7af67c77',
            truncate: true,
            expected: 'PrettyVersion bbf527a',
        },
        {
            source_reference: 'v1.0.0',
            truncate: false,
            expected: 'PrettyVersion v1.0.0',
        },
        {
            source_reference: 'bbf527a27356414bfa9bf520f018c5cb7af67c77',
            truncate: false,
            expected: 'PrettyVersion bbf527a27356414bfa9bf520f018c5cb7af67c77',
        },

    ].each do |test|

      it "succeeds on #{test[:source_reference]} with truncate: #{test[:truncate]}" do

        allow(package).to receive(:is_dev?).once.and_return(true)
        allow(package).to receive(:source_type).once.and_return('git')
        allow(package).to receive(:pretty_version).once.and_return('PrettyVersion')
        allow(package).to receive(:source_reference).and_return(test[:source_reference])
        allow(package).to receive(:full_pretty_version).and_call_original

        expect( package.full_pretty_version(test[:truncate]) ).to be == test[:expected]

      end
    end

  end

end
