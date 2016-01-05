require_relative '../../../spec_helper'

describe ::Composer::Util::ComposerMirror do

  let(:util) { described_class }

  context ':process_url' do

    let(:package_name) {'foo'}
    let(:version) { '1.0.0.0' }
    let(:type) { 'git' }

    it 'succeeds on reference be5d2593866abbf7316460ecebb1ad3b421d351d' do

      reference = 'be5d2593866abbf7316460ecebb1ad3b421d351d'
      mirror_url = 'http://mirror.com/%package%/%version%/%reference%/%type%/'
      expected = "http://mirror.com/#{package_name}/#{version}/#{reference}/#{type}/"
      expect( util.process_url(mirror_url, package_name, version, reference, type)).to be == expected

    end

    it 'succeeds on reference tree/1.0.0-alpha11' do

      reference = 'tree/1.0.0-alpha11'
      mirror_url = 'http://mirror.com/%package%/%version%/%reference%/%type%/'
      expected = "http://mirror.com/#{package_name}/#{version}/#{Digest::MD5.hexdigest(reference)}/#{type}/"
      expect( util.process_url(mirror_url, package_name, version, reference, type)).to be == expected

    end

    it 'succeeds on reference %reference%' do

      reference = '%reference%'
      mirror_url = 'http://mirror.com/%package%/%version%/%reference%/%type%/'
      expected = "http://mirror.com/#{package_name}/#{version}/%reference%/#{type}/"
      expect( util.process_url(mirror_url, package_name, version, reference, type)).to be == expected

    end

    it 'succeeds on version 1.0.0-alpha11' do

      version = '1.0.0-alpha1'
      reference = 'be5d2593866abbf7316460ecebb1ad3b421d351d'
      mirror_url = 'http://mirror.com/%package%/%version%/%reference%/%type%/'
      expected = "http://mirror.com/#{package_name}/#{version}/#{reference}/#{type}/"
      expect( util.process_url(mirror_url, package_name, version, reference, type)).to be == expected

    end

    it 'succeeds on version 1.0.0/alpha11' do

      version = '1.0.0/alpha1'
      reference = 'be5d2593866abbf7316460ecebb1ad3b421d351d'
      mirror_url = 'http://mirror.com/%package%/%version%/%reference%/%type%/'
      expected = "http://mirror.com/#{package_name}/#{Digest::MD5.hexdigest(version)}/#{reference}/#{type}/"
      expect( util.process_url(mirror_url, package_name, version, reference, type)).to be == expected

    end

  end

  context ':process_git_url' do

    [
        {
            url: 'http://github.com/sample/project',
            expected: 'http://mirror.com/gh-sample/project'
        },
        {
            url: 'http://github.com/sample/project.git',
            expected: 'http://mirror.com/gh-sample/project'
        },

        {
            url: 'https://github.com/sample/project',
            expected: 'http://mirror.com/gh-sample/project'
        },
        {
            url: 'https://github.com/sample/project.git',
            expected: 'http://mirror.com/gh-sample/project'
        },
        {
            url: 'git://github.com/sample/project',
            expected: 'http://mirror.com/gh-sample/project'
        },
        {
            url: 'git://github.com/sample/project.git',
            expected: 'http://mirror.com/gh-sample/project'
        },

        {
            url: 'git@github.com:sample/project',
            expected: 'http://mirror.com/gh-sample/project'
        },
        {
            url: 'git@github.com:sample/project.git',
            expected: 'http://mirror.com/gh-sample/project'
        },

        {
            url: 'https://bitbucket.org/sample/project',
            expected: 'http://mirror.com/bb-sample/project'
        },
        {
            url: 'https://bitbucket.org/sample/project/',
            expected: 'http://mirror.com/bb-sample/project'
        },
        {
            url: 'https://bitbucket.org/sample/project.git',
            expected: 'http://mirror.com/bb-sample/project'
        },

        {
            url: 'https://bitbucket.org/sample/project.git/',
            expected: 'http://mirror.com/bb-sample/project'
        },

        {
            url: 'http://example.com/sample/project',
            expected: 'http://mirror.com/http---example.com-sample-project'
        },
        {
            url: 'http://example.com/sample/project.git',
            expected: 'http://mirror.com/http---example.com-sample-project.git'
        },

        {
            url: 'https://example.com/sample/project',
            expected: 'http://mirror.com/https---example.com-sample-project'
        },
        {
            url: 'https://example.com/sample/project.git',
            expected: 'http://mirror.com/https---example.com-sample-project.git'
        },

    ].each do |test|

      mirror_url = 'http://mirror.com/%normalizedUrl%/%package%/%type%/'
      package_name = 'foo'

      it "succeeds on dist #{test[:url]}" do

        expect( util.process_git_url(mirror_url, package_name, test[:url], 'dist')).to be == "#{test[:expected]}/#{package_name}/dist/"

      end

    end

  end

end
