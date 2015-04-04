require 'digest/crc32'

module Composer
  module Package
    module Loader

      # Loads a package from project attributes
      # @author Ioannis Kappas <ikappas@devworks.gr>
      class ProjectAttributesLoader

        def initialize(loader)
          @loader = loader
        end

        # Load a json string or file
        # Param:  string|JsonFile json A filename, json string or JsonFile instance to load the package from
        # Returns: Composer::Package::Package
        def load(project, ref, type = 'library')

          version = (ref.instance_of?(Gitlab::Git::Branch)) ? "dev-#{ref.name}" : ref.name

          config = {
            'name'                => project.path_with_namespace.gsub(/\s/, '').downcase,
            'description'         => project.description,
            'version'             => version,
            'uid'                 => Digest::CRC32.checksum(ref.name + ref.target),
            'source'              => {
              'url'                 => project.url_to_repo,
              'type'                => 'git',
              'reference'           => ref.target
            },
            'dist'                => {
              'url'                 => [project.web_url, 'repository', 'archive.zip?ref=' + ref.name].join('/'),
              'type'                => 'zip'
            },
            'type'                => type,
            'homepage'            => project.web_url
          }

          if time = get_time(project, ref)
            log("Ref: #{ref.to_json} Time: #{time}")
            config['time'] = time
          end

          if keywords = get_keywords(project)
            config['keywords'] = keywords
          end

          @loader.load(config)
        end

        private

        def get_time(project, ref)
          commit = project.repository.commit(ref.target)
          commit.committed_date.strftime('%Y-%m-%d %H:%M:%S')
        rescue
          # If there's a problem, just skip the "time" field
        end

        def get_keywords(project)
          project.tags.collect { |t| t['name'] }
        end

        def log(message)
          Gitlab::AppLogger.error("ComposerService: #{message}")
        end
      end
    end
  end
end
